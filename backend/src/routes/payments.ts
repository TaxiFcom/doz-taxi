import { Router, Request, Response, NextFunction } from 'express';
import { body } from 'express-validator';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { paymentService } from '../services/paymentService';
import { getPagination } from '../utils/helpers';

const router = Router();

router.get('/wallet', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const wallet = await paymentService.getWallet(req.user!.id);
    res.json({ success: true, data: wallet });
  } catch (err) { next(err); }
});

router.post('/wallet/topup', authenticate,
  [body('amount').isFloat({ min: 1, max: 1000 }), body('method').isIn(['CARD', 'BANK_TRANSFER', 'CASH'])],
  validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await paymentService.topupWallet(req.user!.id, parseFloat(req.body.amount), req.body.method);
      res.json({ success: true, message: 'Wallet topped up successfully', data: result });
    } catch (err) { next(err); }
  }
);

router.get('/wallet/transactions', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page, limit } = getPagination(req.query);
    const result = await paymentService.getTransactions(req.user!.id, page, limit);
    res.json({ success: true, ...result });
  } catch (err) { next(err); }
});

router.post('/pay', authenticate,
  [body('ride_id').isUUID(), body('method').isIn(['CASH', 'WALLET', 'CARD'])],
  validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const payment = await paymentService.processRidePayment(req.body.ride_id, req.user!.id, req.body.method);
      res.json({ success: true, message: 'Payment processed', data: payment });
    } catch (err) { next(err); }
  }
);

export default router;
