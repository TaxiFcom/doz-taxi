import { Router, Request, Response, NextFunction } from 'express';
import { body } from 'express-validator';
import { authenticate, authorize } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { rideService } from '../services/rideService';
import { createError } from '../middleware/errorHandler';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

router.post('/', authenticate, authorize('RIDER'),
  [
    body('pickup_lat').isFloat({ min: -90, max: 90 }),
    body('pickup_lng').isFloat({ min: -180, max: 180 }),
    body('pickup_address').trim().notEmpty(),
    body('dropoff_lat').isFloat({ min: -90, max: 90 }),
    body('dropoff_lng').isFloat({ min: -180, max: 180 }),
    body('dropoff_address').trim().notEmpty(),
    body('vehicle_type_id').optional().isUUID(),
    body('payment_method').optional().isIn(['CASH', 'WALLET', 'CARD']),
    body('promo_code').optional().trim(),
  ],
  validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const ride = await rideService.createRide({
        riderId: req.user!.id,
        pickupLat: parseFloat(req.body.pickup_lat),
        pickupLng: parseFloat(req.body.pickup_lng),
        pickupAddress: req.body.pickup_address,
        dropoffLat: parseFloat(req.body.dropoff_lat),
        dropoffLng: parseFloat(req.body.dropoff_lng),
        dropoffAddress: req.body.dropoff_address,
        vehicleTypeId: req.body.vehicle_type_id,
        paymentMethod: req.body.payment_method,
        promoCode: req.body.promo_code,
      });
      res.status(201).json({ success: true, message: 'Ride request created', data: ride });
    } catch (err) { next(err); }
  }
);

router.get('/', authenticate, async (req, res, next) => {
  try { const result = await rideService.listRides(req.user!.id, req.user!.role, req.query); res.json({ success: true, ...result }); } catch (err) { next(err); }
});

router.get('/:id', authenticate, async (req, res, next) => {
  try { const ride = await rideService.getRide(req.params.id, req.user!.id); res.json({ success: true, data: ride }); } catch (err) { next(err); }
});

router.put('/:id/cancel', authenticate, [body('reason').optional().trim().isLength({ max: 255 })], validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try { const ride = await rideService.cancelRide(req.params.id, req.user!.id, req.body.reason); res.json({ success: true, message: 'Ride cancelled', data: ride }); } catch (err) { next(err); }
  }
);

router.put('/:id/arrive', authenticate, authorize('DRIVER'), async (req, res, next) => {
  try {
    const driver = await prisma.driver.findUnique({ where: { user_id: req.user!.id } });
    if (!driver) throw createError('Driver profile not found', 404);
    const ride = await rideService.driverArrived(req.params.id, driver.id);
    res.json({ success: true, message: 'Arrival confirmed', data: ride });
  } catch (err) { next(err); }
});

router.put('/:id/start', authenticate, authorize('DRIVER'), async (req, res, next) => {
  try {
    const driver = await prisma.driver.findUnique({ where: { user_id: req.user!.id } });
    if (!driver) throw createError('Driver profile not found', 404);
    const ride = await rideService.startRide(req.params.id, driver.id);
    res.json({ success: true, message: 'Ride started', data: ride });
  } catch (err) { next(err); }
});

router.put('/:id/complete', authenticate, authorize('DRIVER'), async (req, res, next) => {
  try {
    const driver = await prisma.driver.findUnique({ where: { user_id: req.user!.id } });
    if (!driver) throw createError('Driver profile not found', 404);
    const ride = await rideService.completeRide(req.params.id, driver.id);
    res.json({ success: true, message: 'Ride completed', data: ride });
  } catch (err) { next(err); }
});

router.post('/:id/rate', authenticate,
  [body('stars').isInt({ min: 1, max: 5 }), body('tags').optional().isArray(), body('comment').optional().trim().isLength({ max: 500 })],
  validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const rating = await rideService.rateRide(req.params.id, req.user!.id, req.body.stars, req.body.tags, req.body.comment);
      res.json({ success: true, message: 'Rating submitted', data: rating });
    } catch (err) { next(err); }
  }
);

export default router;
