import { Router, Request, Response, NextFunction } from 'express';
import { body } from 'express-validator';
import { authenticate, authorize } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { bidService } from '../services/bidService';
import { createError } from '../middleware/errorHandler';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// ─── Create Bid ───────────────────────────────────────────────────────────────
router.post(
  '/',
  authenticate,
  authorize('DRIVER'),
  [
    body('ride_id').isUUID().withMessage('Valid ride ID required'),
    body('amount').isFloat({ min: 0.1 }).withMessage('Amount must be a positive number'),
    body('note').optional().trim().isLength({ max: 200 }),
    body('eta_min').optional().isInt({ min: 1, max: 120 }),
  ],
  validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const driver = await prisma.driver.findUnique({ where: { user_id: req.user!.id } });
      if (!driver) throw createError('Driver profile not found', 404);

      const bid = await bidService.createBid(
        driver.id,
        req.body.ride_id,
        parseFloat(req.body.amount),
        req.body.note,
        req.body.eta_min ? parseInt(req.body.eta_min) : undefined
      );

      res.status(201).json({ success: true, message: 'Bid submitted', data: bid });
    } catch (err) {
      next(err);
    }
  }
);

// ─── Get Bids for a Ride ──────────────────────────────────────────────────────
router.get(
  '/ride/:rideId',
  authenticate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const bids = await bidService.getBidsForRide(req.params.rideId, req.user!.id);
      res.json({ success: true, data: bids });
    } catch (err) {
      next(err);
    }
  }
);

// ─── Accept Bid ───────────────────────────────────────────────────────────────
router.put(
  '/:id/accept',
  authenticate,
  authorize('RIDER'),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await bidService.acceptBid(req.params.id, req.user!.id);
      res.json({ success: true, message: 'Bid accepted', data: result });
    } catch (err) {
      next(err);
    }
  }
);

// ─── Reject Bid ───────────────────────────────────────────────────────────────
router.put(
  '/:id/reject',
  authenticate,
  authorize('RIDER'),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const bid = await bidService.rejectBid(req.params.id, req.user!.id);
      res.json({ success: true, message: 'Bid rejected', data: bid });
    } catch (err) {
      next(err);
    }
  }
);

export default router;
