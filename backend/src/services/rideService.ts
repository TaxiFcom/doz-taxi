import { PrismaClient, RideStatus, PaymentMethod } from '@prisma/client';
import { eventBus, CHANNELS } from './eventBus';
import { notificationService } from './notificationService';
import { createError } from '../middleware/errorHandler';
import { haversineDistance, estimateDuration, estimatePrice, getBoundingBox } from './locationService';

const prisma = new PrismaClient();

export const rideService = {
  async createRide(params: { riderId: string; pickupLat: number; pickupLng: number; pickupAddress: string; dropoffLat: number; dropoffLng: number; dropoffAddress: string; vehicleTypeId?: string; paymentMethod?: PaymentMethod; promoCode?: string; }): Promise<any> {
    const distanceKm = haversineDistance(params.pickupLat, params.pickupLng, params.dropoffLat, params.dropoffLng);
    const durationMin = estimateDuration(distanceKm);
    let suggestedPrice: number | undefined;
    if (params.vehicleTypeId) {
      const vType = await prisma.vehicleType.findUnique({ where: { id: params.vehicleTypeId } });
      if (vType) { suggestedPrice = estimatePrice(distanceKm, durationMin, vType.base_fare, vType.per_km, vType.per_min, vType.min_fare); }
    }
    let discountAmount = 0;
    if (params.promoCode) {
      const promo = await prisma.promoCode.findUnique({ where: { code: params.promoCode.toUpperCase() } });
      if (promo && promo.is_active && promo.valid_until > new Date() && promo.current_uses < promo.max_uses) {
        if (suggestedPrice) {
          discountAmount = promo.discount_type === 'PERCENTAGE' ? suggestedPrice * (promo.discount_value / 100) : promo.discount_value;
          suggestedPrice = Math.max(0, suggestedPrice - discountAmount);
          await prisma.promoCode.update({ where: { id: promo.id }, data: { current_uses: { increment: 1 } } });
        }
      }
    }
    const ride = await prisma.ride.create({
      data: { rider_id: params.riderId, status: RideStatus.PENDING, pickup_lat: params.pickupLat, pickup_lng: params.pickupLng, pickup_address: params.pickupAddress, dropoff_lat: params.dropoffLat, dropoff_lng: params.dropoffLng, dropoff_address: params.dropoffAddress, distance_km: Math.round(distanceKm * 10) / 10, duration_min: Math.round(durationMin), suggested_price: suggestedPrice ? Math.round(suggestedPrice * 100) / 100 : null, vehicle_type_id: params.vehicleTypeId, payment_method: params.paymentMethod || PaymentMethod.CASH, promo_code: params.promoCode, discount_amount: discountAmount || null },
      include: { rider: { select: { id: true, name: true, phone: true, avatar_url: true } } },
    });
    await this._notifyNearbyDrivers(ride, params.pickupLat, params.pickupLng);
    return ride;
  },

  async _notifyNearbyDrivers(ride: any, lat: number, lng: number, radiusKm = 10): Promise<void> {
    const bbox = getBoundingBox(lat, lng, radiusKm);
    const nearbyDrivers = await prisma.driver.findMany({ where: { is_online: true, is_busy: false, is_approved: true, lat: { gte: bbox.minLat, lte: bbox.maxLat }, lng: { gte: bbox.minLng, lte: bbox.maxLng } }, include: { user: { select: { id: true } } } });
    const event = { type: 'ride:new', ride: { id: ride.id, pickup_address: ride.pickup_address, dropoff_address: ride.dropoff_address, pickup_lat: ride.pickup_lat, pickup_lng: ride.pickup_lng, dropoff_lat: ride.dropoff_lat, dropoff_lng: ride.dropoff_lng, distance_km: ride.distance_km, duration_min: ride.duration_min, suggested_price: ride.suggested_price, vehicle_type_id: ride.vehicle_type_id, created_at: ride.created_at } };
    for (const driver of nearbyDrivers) {
      const distance = haversineDistance(lat, lng, driver.lat, driver.lng);
      if (distance <= radiusKm) { eventBus.publish(CHANNELS.RIDE_NEW(driver.user.id), event); }
    }
  },

  async getRide(rideId: string, userId: string): Promise<any> {
    const ride = await prisma.ride.findUnique({
      where: { id: rideId },
      include: { rider: { select: { id: true, name: true, phone: true, avatar_url: true } }, driver: { include: { user: { select: { id: true, name: true, phone: true, avatar_url: true } } } }, bids: { where: { status: 'PENDING' }, include: { driver: { include: { user: { select: { name: true, avatar_url: true } } } } }, orderBy: { created_at: 'asc' } }, ratings: true },
    });
    if (!ride) throw createError('Ride not found', 404);
    return ride;
  },

  async cancelRide(rideId: string, userId: string, reason?: string): Promise<any> {
    const ride = await prisma.ride.findUnique({ where: { id: rideId }, include: { driver: { include: { user: { select: { id: true } } } } } });
    if (!ride) throw createError('Ride not found', 404);
    const cancellableStatuses = [RideStatus.PENDING, RideStatus.BIDDING, RideStatus.ACCEPTED, RideStatus.DRIVER_ARRIVING];
    if (!cancellableStatuses.includes(ride.status)) throw createError(`Cannot cancel a ride with status ${ride.status}`, 400);
    const isRider = ride.rider_id === userId;
    const isDriver = ride.driver?.user?.id === userId;
    if (!isRider && !isDriver) throw createError('Unauthorized to cancel this ride', 403);
    const updatedRide = await prisma.$transaction(async (tx) => {
      const updated = await tx.ride.update({ where: { id: rideId }, data: { status: RideStatus.CANCELLED, cancelled_at: new Date(), cancel_reason: reason || 'Cancelled by user' } });
      if (ride.driver_id) { await tx.driver.update({ where: { id: ride.driver_id }, data: { is_busy: false } }); }
      await tx.bid.updateMany({ where: { ride_id: rideId, status: 'PENDING' }, data: { status: 'EXPIRED' } });
      return updated;
    });
    if (isRider && ride.driver?.user.id) { await notificationService.notifyRideCancelled(ride.driver.user.id, rideId, reason); }
    else if (isDriver) { await notificationService.notifyRideCancelled(ride.rider_id, rideId, reason); }
    eventBus.publish(CHANNELS.RIDE_UPDATE(rideId), { type: 'ride:cancelled', rideId, reason });
    return updatedRide;
  },

  async driverArrived(rideId: string, driverId: string): Promise<any> {
    const ride = await prisma.ride.findUnique({ where: { id: rideId }, include: { driver: { include: { user: { select: { id: true, name: true } } } } } });
    if (!ride) throw createError('Ride not found', 404);
    if (ride.driver_id !== driverId) throw createError('Unauthorized', 403);
    if (ride.status !== RideStatus.ACCEPTED) throw createError('Invalid ride status', 400);
    const updated = await prisma.ride.update({ where: { id: rideId }, data: { status: RideStatus.DRIVER_ARRIVING } });
    await notificationService.notifyDriverArriving(ride.rider_id, rideId, ride.driver?.user.name || 'Driver', 2);
    eventBus.publish(CHANNELS.RIDE_UPDATE(rideId), { type: 'ride:driver-arriving', rideId });
    return updated;
  },

  async startRide(rideId: string, driverId: string): Promise<any> {
    const ride = await prisma.ride.findUnique({ where: { id: rideId } });
    if (!ride) throw createError('Ride not found', 404);
    if (ride.driver_id !== driverId) throw createError('Unauthorized', 403);
    if (ride.status !== RideStatus.DRIVER_ARRIVING && ride.status !== RideStatus.ACCEPTED) throw createError('Invalid ride status to start', 400);
    const updated = await prisma.ride.update({ where: { id: rideId }, data: { status: RideStatus.IN_PROGRESS, started_at: new Date() } });
    await notificationService.notifyRideStarted(ride.rider_id, rideId);
    eventBus.publish(CHANNELS.RIDE_UPDATE(rideId), { type: 'ride:started', rideId, startedAt: updated.started_at });
    return updated;
  },

  async completeRide(rideId: string, driverId: string): Promise<any> {
    const ride = await prisma.ride.findUnique({ where: { id: rideId }, include: { driver: { include: { user: { select: { id: true } } } } } });
    if (!ride) throw createError('Ride not found', 404);
    if (ride.driver_id !== driverId) throw createError('Unauthorized', 403);
    if (ride.status !== RideStatus.IN_PROGRESS) throw createError('Ride is not in progress', 400);
    const completedAt = new Date();
    const durationMin = ride.started_at ? (completedAt.getTime() - ride.started_at.getTime()) / 60000 : ride.duration_min || 0;
    const updated = await prisma.$transaction(async (tx) => {
      const updatedRide = await tx.ride.update({ where: { id: rideId }, data: { status: RideStatus.COMPLETED, completed_at: completedAt, duration_min: Math.round(durationMin) } });
      await tx.driver.update({ where: { id: driverId }, data: { total_rides: { increment: 1 }, is_busy: false } });
      return updatedRide;
    });
    if (ride.driver?.user.id) { await notificationService.notifyRideCompleted(ride.rider_id, ride.driver.user.id, rideId, ride.final_price || 0); }
    eventBus.publish(CHANNELS.RIDE_UPDATE(rideId), { type: 'ride:completed', rideId, finalPrice: ride.final_price, completedAt });
    return updated;
  },

  async rateRide(rideId: string, fromUserId: string, stars: number, tags?: string[], comment?: string): Promise<any> {
    const ride = await prisma.ride.findUnique({ where: { id: rideId }, include: { driver: { include: { user: { select: { id: true } } } } } });
    if (!ride) throw createError('Ride not found', 404);
    if (ride.status !== RideStatus.COMPLETED) throw createError('Can only rate completed rides', 400);
    const isRider = ride.rider_id === fromUserId;
    const isDriver = ride.driver?.user.id === fromUserId;
    if (!isRider && !isDriver) throw createError('Unauthorized to rate this ride', 403);
    if (isRider && ride.rated_by_rider) throw createError('Already rated', 400);
    if (isDriver && ride.rated_by_driver) throw createError('Already rated', 400);
    let toUserId: string;
    if (isRider) { if (!ride.driver?.user.id) throw createError('Driver not found', 404); toUserId = ride.driver.user.id; }
    else { toUserId = ride.rider_id; }
    const result = await prisma.$transaction(async (tx) => {
      const rating = await tx.rating.create({ data: { ride_id: rideId, from_user_id: fromUserId, to_user_id: toUserId, stars, tags: tags ? tags.join(',') : null, comment } });
      await tx.ride.update({ where: { id: rideId }, data: isRider ? { rated_by_rider: true } : { rated_by_driver: true } });
      if (isRider && ride.driver_id) {
        const ratings = await tx.rating.findMany({ where: { to_user_id: toUserId }, select: { stars: true } });
        const avgRating = ratings.reduce((sum, r) => sum + r.stars, 0) / ratings.length;
        await tx.driver.update({ where: { user_id: toUserId }, data: { rating: Math.round(avgRating * 10) / 10 } });
      }
      return rating;
    });
    return result;
  },

  async listRides(userId: string, role: string, query: any): Promise<any> {
    const { page = 1, limit = 20, status, from, to } = query;
    const skip = (page - 1) * limit;
    const where: any = {};
    if (role === 'RIDER') { where.rider_id = userId; }
    else if (role === 'DRIVER') {
      const driver = await prisma.driver.findUnique({ where: { user_id: userId } });
      if (driver) where.driver_id = driver.id;
      else return { data: [], meta: { total: 0 } };
    }
    if (status) where.status = status;
    if (from || to) { where.created_at = {}; if (from) where.created_at.gte = new Date(from); if (to) where.created_at.lte = new Date(to); }
    const [rides, total] = await Promise.all([
      prisma.ride.findMany({ where, include: { rider: { select: { id: true, name: true, avatar_url: true } }, driver: { include: { user: { select: { id: true, name: true, avatar_url: true } } } } }, orderBy: { created_at: 'desc' }, skip, take: parseInt(limit) }),
      prisma.ride.count({ where }),
    ]);
    return { data: rides, meta: { total, page: parseInt(page), limit: parseInt(limit), totalPages: Math.ceil(total / parseInt(limit)), hasMore: parseInt(page) * parseInt(limit) < total } };
  },
};
