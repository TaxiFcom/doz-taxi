import { PrismaClient, BidStatus, RideStatus } from '@prisma/client';
import { eventBus, CHANNELS } from './eventBus';
import { notificationService } from './notificationService';
import { createError } from '../middleware/errorHandler';

const prisma = new PrismaClient();

export const bidService = {
  async createBid(driverId: string, rideId: string, amount: number, note?: string, etaMin?: number): Promise<any> {
    const ride = await prisma.ride.findUnique({ where: { id: rideId }, include: { rider: { select: { id: true, name: true } } } });
    if (!ride) throw createError('Ride not found', 404);
    if (ride.status !== RideStatus.PENDING && ride.status !== RideStatus.BIDDING) {
      throw createError('Ride is not accepting bids', 400);
    }
    const driver = await prisma.driver.findUnique({ where: { id: driverId }, include: { user: { select: { name: true } } } });
    if (!driver) throw createError('Driver profile not found', 404);
    if (!driver.is_approved) throw createError('Driver not approved', 403);
    if (!driver.is_online) throw createError('Driver must be online to bid', 400);
    if (driver.is_busy) throw createError('Driver is currently busy', 400);
    const existingBid = await prisma.bid.findFirst({ where: { ride_id: rideId, driver_id: driverId, status: BidStatus.PENDING } });
    if (existingBid) throw createError('You already have a pending bid on this ride', 400);
    if (ride.status === RideStatus.PENDING) {
      await prisma.ride.update({ where: { id: rideId }, data: { status: RideStatus.BIDDING } });
    }
    const bid = await prisma.bid.create({
      data: { ride_id: rideId, driver_id: driverId, amount, status: BidStatus.PENDING, note, eta_min: etaMin },
      include: { driver: { include: { user: { select: { id: true, name: true, avatar_url: true } } } } },
    });
    await notificationService.notifyRiderNewBid(ride.rider_id, rideId, bid.id, amount, driver.user.name);
    eventBus.publish(CHANNELS.BID_RECEIVED(rideId), {
      type: 'bid:received',
      bid: { id: bid.id, ride_id: rideId, amount, eta_min: etaMin, note, driver: { id: driver.id, name: driver.user.name, rating: driver.rating, total_rides: driver.total_rides, vehicle_model: driver.vehicle_model, vehicle_color: driver.vehicle_color, plate_number: driver.plate_number }, created_at: bid.created_at },
    });
    return bid;
  },

  async acceptBid(bidId: string, riderId: string): Promise<any> {
    const bid = await prisma.bid.findUnique({
      where: { id: bidId },
      include: { ride: true, driver: { include: { user: { select: { id: true, name: true } } } } },
    });
    if (!bid) throw createError('Bid not found', 404);
    if (bid.ride.rider_id !== riderId) throw createError('Unauthorized', 403);
    if (bid.status !== BidStatus.PENDING) throw createError('Bid is no longer available', 400);
    if (bid.ride.status !== RideStatus.BIDDING && bid.ride.status !== RideStatus.PENDING) {
      throw createError('Ride is not in bidding state', 400);
    }
    const result = await prisma.$transaction(async (tx) => {
      const updatedBid = await tx.bid.update({ where: { id: bidId }, data: { status: BidStatus.ACCEPTED } });
      await tx.bid.updateMany({ where: { ride_id: bid.ride_id, id: { not: bidId }, status: BidStatus.PENDING }, data: { status: BidStatus.REJECTED } });
      const commission = bid.amount * bid.driver.commission_rate;
      const updatedRide = await tx.ride.update({ where: { id: bid.ride_id }, data: { driver_id: bid.driver_id, status: RideStatus.ACCEPTED, final_price: bid.amount, commission_amount: commission } });
      await tx.driver.update({ where: { id: bid.driver_id }, data: { is_busy: true } });
      return { bid: updatedBid, ride: updatedRide };
    });
    await notificationService.notifyDriverBidAccepted(bid.driver.user.id, bid.ride_id);
    eventBus.publish(CHANNELS.BID_ACCEPTED(bid.driver_id), { type: 'bid:accepted', rideId: bid.ride_id, bidId });
    eventBus.publish(CHANNELS.RIDE_UPDATE(bid.ride_id), { type: 'ride:accepted', rideId: bid.ride_id, driver: { id: bid.driver.id, name: bid.driver.user.name, rating: bid.driver.rating, vehicle_model: bid.driver.vehicle_model, plate_number: bid.driver.plate_number } });
    return result;
  },

  async rejectBid(bidId: string, riderId: string): Promise<any> {
    const bid = await prisma.bid.findUnique({ where: { id: bidId }, include: { ride: true } });
    if (!bid) throw createError('Bid not found', 404);
    if (bid.ride.rider_id !== riderId) throw createError('Unauthorized', 403);
    if (bid.status !== BidStatus.PENDING) throw createError('Bid is no longer pending', 400);
    return prisma.bid.update({ where: { id: bidId }, data: { status: BidStatus.REJECTED } });
  },

  async getBidsForRide(rideId: string, userId: string): Promise<any[]> {
    const ride = await prisma.ride.findUnique({ where: { id: rideId } });
    if (!ride) throw createError('Ride not found', 404);
    if (ride.rider_id !== userId) {
      const driverBid = await prisma.bid.findFirst({ where: { ride_id: rideId, driver: { user_id: userId } } });
      if (!driverBid) throw createError('Unauthorized', 403);
    }
    return prisma.bid.findMany({
      where: { ride_id: rideId },
      include: { driver: { include: { user: { select: { id: true, name: true, avatar_url: true } } } } },
      orderBy: { created_at: 'asc' },
    });
  },
};
