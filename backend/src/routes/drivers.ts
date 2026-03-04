import { Router, Request, Response, NextFunction } from 'express';
import { body } from 'express-validator';
import { authenticate, authorize } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { createError } from '../middleware/errorHandler';
import { PrismaClient } from '@prisma/client';
import { haversineDistance, getBoundingBox, sortDriversByDistance } from '../services/locationService';
import { eventBus, CHANNELS } from '../services/eventBus';

const router = Router();
const prisma = new PrismaClient();

// Toggle Online Status
router.put('/status', authenticate, authorize('DRIVER'),
  [body('is_online').isBoolean()], validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const driver = await prisma.driver.findUnique({ where: { user_id: req.user!.id } });
      if (!driver) throw createError('Driver profile not found', 404);
      if (!driver.is_approved) throw createError('Driver account not approved yet', 403);
      const updated = await prisma.driver.update({ where: { id: driver.id }, data: { is_online: req.body.is_online } });
      res.json({ success: true, message: `Driver is now ${req.body.is_online ? 'online' : 'offline'}`, data: updated });
    } catch (err) { next(err); }
  }
);

// Update Location
router.put('/location', authenticate, authorize('DRIVER'),
  [body('lat').isFloat({ min: -90, max: 90 }), body('lng').isFloat({ min: -180, max: 180 }), body('heading').optional().isFloat({ min: 0, max: 360 })],
  validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const driver = await prisma.driver.findUnique({ where: { user_id: req.user!.id } });
      if (!driver) throw createError('Driver profile not found', 404);
      const updated = await prisma.driver.update({ where: { id: driver.id }, data: { lat: req.body.lat, lng: req.body.lng, heading: req.body.heading ?? driver.heading } });
      if (driver.is_busy) {
        const activeRide = await prisma.ride.findFirst({ where: { driver_id: driver.id, status: { in: ['ACCEPTED', 'DRIVER_ARRIVING', 'IN_PROGRESS'] } } });
        if (activeRide) {
          eventBus.publish(CHANNELS.DRIVER_LOCATION(activeRide.id), { type: 'driver:location', rideId: activeRide.id, lat: req.body.lat, lng: req.body.lng, heading: req.body.heading ?? driver.heading });
        }
      }
      res.json({ success: true, message: 'Location updated', data: { lat: updated.lat, lng: updated.lng } });
    } catch (err) { next(err); }
  }
);

// Find Nearby Drivers
router.get('/nearby', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const lat = parseFloat(req.query.lat as string);
    const lng = parseFloat(req.query.lng as string);
    const radius = Math.min(parseFloat(req.query.radius as string || '10'), 50);
    const vehicleTypeId = req.query.vehicle_type_id as string | undefined;
    if (isNaN(lat) || isNaN(lng)) throw createError('lat and lng required', 400);
    const bbox = getBoundingBox(lat, lng, radius);
    const drivers = await prisma.driver.findMany({
      where: { is_online: true, is_busy: false, is_approved: true, lat: { gte: bbox.minLat, lte: bbox.maxLat }, lng: { gte: bbox.minLng, lte: bbox.maxLng }, ...(vehicleTypeId && { vehicle_type_id: vehicleTypeId }) },
      include: { user: { select: { name: true, avatar_url: true } }, vehicle_type: { select: { name_ar: true, name_en: true, icon: true } } },
      take: 20,
    });
    const withDistance = sortDriversByDistance(drivers.map((d) => ({ ...d, distance: 0 })), lat, lng).filter((d) => d.distance <= radius);
    res.json({
      success: true,
      data: withDistance.map((d) => ({ id: d.id, name: d.user.name, avatar_url: d.user.avatar_url, vehicle_model: d.vehicle_model, vehicle_color: d.vehicle_color, plate_number: d.plate_number, vehicle_type: d.vehicle_type, rating: d.rating, lat: d.lat, lng: d.lng, heading: d.heading, distance_km: Math.round(d.distance * 10) / 10, eta_min: Math.round((d.distance / 30) * 60) })),
    });
  } catch (err) { next(err); }
});

// Get Earnings
router.get('/earnings', authenticate, authorize('DRIVER'), async (req: Request, res: Response, next: NextFunction) => {
  try {
    const driver = await prisma.driver.findUnique({ where: { user_id: req.user!.id } });
    if (!driver) throw createError('Driver profile not found', 404);
    const { period = 'week' } = req.query;
    const now = new Date();
    let fromDate: Date;
    switch (period) {
      case 'today': fromDate = new Date(now.getFullYear(), now.getMonth(), now.getDate()); break;
      case 'week': fromDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000); break;
      case 'month': fromDate = new Date(now.getFullYear(), now.getMonth(), 1); break;
      default: fromDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    }
    const rides = await prisma.ride.findMany({ where: { driver_id: driver.id, status: 'COMPLETED', completed_at: { gte: fromDate } }, select: { id: true, final_price: true, commission_amount: true, completed_at: true, distance_km: true }, orderBy: { completed_at: 'desc' } });
    const totalEarnings = rides.reduce((sum, r) => sum + (r.final_price || 0), 0);
    const totalCommission = rides.reduce((sum, r) => sum + (r.commission_amount || 0), 0);
    const netEarnings = totalEarnings - totalCommission;
    const totalDistance = rides.reduce((sum, r) => sum + (r.distance_km || 0), 0);
    res.json({ success: true, data: { period, total_rides: rides.length, total_earnings: Math.round(totalEarnings * 100) / 100, total_commission: Math.round(totalCommission * 100) / 100, net_earnings: Math.round(netEarnings * 100) / 100, total_distance_km: Math.round(totalDistance * 10) / 10, rides } });
  } catch (err) { next(err); }
});

// Get Driver Stats
router.get('/stats', authenticate, authorize('DRIVER'), async (req: Request, res: Response, next: NextFunction) => {
  try {
    const driver = await prisma.driver.findUnique({ where: { user_id: req.user!.id }, include: { vehicle_type: true } });
    if (!driver) throw createError('Driver profile not found', 404);
    const [totalRides, completedRides, cancelledRides, avgRating] = await Promise.all([
      prisma.ride.count({ where: { driver_id: driver.id } }),
      prisma.ride.count({ where: { driver_id: driver.id, status: 'COMPLETED' } }),
      prisma.ride.count({ where: { driver_id: driver.id, status: 'CANCELLED' } }),
      prisma.rating.aggregate({ where: { to_user_id: req.user!.id }, _avg: { stars: true } }),
    ]);
    const wallet = await prisma.wallet.findUnique({ where: { user_id: req.user!.id } });
    res.json({ success: true, data: { driver: { id: driver.id, rating: driver.rating, total_rides: driver.total_rides, total_earnings: driver.total_earnings, commission_rate: driver.commission_rate, is_online: driver.is_online, is_busy: driver.is_busy, is_approved: driver.is_approved, vehicle_model: driver.vehicle_model, vehicle_color: driver.vehicle_color, plate_number: driver.plate_number, vehicle_type: driver.vehicle_type }, stats: { total_rides: totalRides, completed_rides: completedRides, cancelled_rides: cancelledRides, completion_rate: totalRides > 0 ? Math.round((completedRides / totalRides) * 100) : 100, avg_rating: Math.round((avgRating._avg.stars || 5) * 10) / 10 }, wallet_balance: wallet?.balance || 0 } });
  } catch (err) { next(err); }
});

export default router;
