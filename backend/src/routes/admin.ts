import { Router, Request, Response, NextFunction } from 'express';
import { body } from 'express-validator';
import { authenticate, authorize } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { createError } from '../middleware/errorHandler';
import { getPagination } from '../utils/helpers';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// All admin routes require authentication and ADMIN role
router.use(authenticate, authorize('ADMIN'));

// ─── Dashboard Stats ──────────────────────────────────────────────────────────
router.get('/dashboard', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const now = new Date();
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

    const [
      totalUsers,
      totalDrivers,
      activeDrivers,
      totalRides,
      todayRides,
      completedRides,
      pendingRides,
      todayRevenue,
      monthRevenue,
      recentRides,
    ] = await Promise.all([
      prisma.user.count({ where: { role: 'RIDER' } }),
      prisma.driver.count(),
      prisma.driver.count({ where: { is_online: true } }),
      prisma.ride.count(),
      prisma.ride.count({ where: { created_at: { gte: todayStart } } }),
      prisma.ride.count({ where: { status: 'COMPLETED' } }),
      prisma.ride.count({ where: { status: { in: ['PENDING', 'BIDDING'] } } }),
      prisma.ride.aggregate({
        where: { status: 'COMPLETED', completed_at: { gte: todayStart } },
        _sum: { commission_amount: true },
      }),
      prisma.ride.aggregate({
        where: { status: 'COMPLETED', completed_at: { gte: monthStart } },
        _sum: { commission_amount: true, final_price: true },
      }),
      prisma.ride.findMany({
        take: 10,
        orderBy: { created_at: 'desc' },
        include: {
          rider: { select: { name: true } },
          driver: { include: { user: { select: { name: true } } } },
        },
      }),
    ]);

    res.json({
      success: true,
      data: {
        overview: {
          total_users: totalUsers,
          total_drivers: totalDrivers,
          active_drivers: activeDrivers,
          total_rides: totalRides,
          today_rides: todayRides,
          completed_rides: completedRides,
          pending_rides: pendingRides,
        },
        revenue: {
          today_commission: todayRevenue._sum.commission_amount || 0,
          month_commission: monthRevenue._sum.commission_amount || 0,
          month_gross: monthRevenue._sum.final_price || 0,
        },
        recent_rides: recentRides,
      },
    });
  } catch (err) {
    next(err);
  }
});

// ─── List Rides ───────────────────────────────────────────────────────────────
router.get('/rides', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page, limit, skip } = getPagination(req.query);
    const { status, from, to, rider_id, driver_id } = req.query;

    const where: any = {};
    if (status) where.status = status;
    if (rider_id) where.rider_id = rider_id;
    if (driver_id) {
      const driver = await prisma.driver.findFirst({ where: { user_id: driver_id as string } });
      if (driver) where.driver_id = driver.id;
    }
    if (from || to) {
      where.created_at = {};
      if (from) where.created_at.gte = new Date(from as string);
      if (to) where.created_at.lte = new Date(to as string);
    }

    const [rides, total] = await Promise.all([
      prisma.ride.findMany({
        where,
        include: {
          rider: { select: { id: true, name: true, phone: true } },
          driver: { include: { user: { select: { id: true, name: true, phone: true } } } },
        },
        orderBy: { created_at: 'desc' },
        skip,
        take: limit,
      }),
      prisma.ride.count({ where }),
    ]);

    res.json({
      success: true,
      data: rides,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit), hasMore: page * limit < total },
    });
  } catch (err) {
    next(err);
  }
});

// ─── List Users ───────────────────────────────────────────────────────────────
router.get('/users', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page, limit, skip } = getPagination(req.query);
    const { role, is_active, search } = req.query;

    const where: any = {};
    if (role) where.role = role;
    if (is_active !== undefined) where.is_active = is_active === 'true';
    if (search) {
      where.OR = [
        { name: { contains: search as string } },
        { phone: { contains: search as string } },
        { email: { contains: search as string } },
      ];
    }

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where,
        select: {
          id: true, name: true, phone: true, email: true, role: true,
          is_active: true, is_verified: true, lang: true, avatar_url: true,
          created_at: true, wallet: { select: { balance: true } },
        },
        orderBy: { created_at: 'desc' },
        skip,
        take: limit,
      }),
      prisma.user.count({ where }),
    ]);

    res.json({
      success: true,
      data: users,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit), hasMore: page * limit < total },
    });
  } catch (err) {
    next(err);
  }
});

// ─── Update User ──────────────────────────────────────────────────────────────
router.put(
  '/users/:id',
  [
    body('is_active').optional().isBoolean(),
    body('is_verified').optional().isBoolean(),
    body('role').optional().isIn(['RIDER', 'DRIVER', 'ADMIN']),
  ],
  validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = await prisma.user.findUnique({ where: { id: req.params.id } });
      if (!user) throw createError('User not found', 404);

      const { is_active, is_verified, role } = req.body;
      const updateData: any = {};
      if (is_active !== undefined) updateData.is_active = is_active;
      if (is_verified !== undefined) updateData.is_verified = is_verified;
      if (role) updateData.role = role;

      const updated = await prisma.user.update({
        where: { id: req.params.id },
        data: updateData,
        select: { id: true, name: true, role: true, is_active: true, is_verified: true },
      });

      res.json({ success: true, message: 'User updated', data: updated });
    } catch (err) {
      next(err);
    }
  }
);

// ─── List Drivers ─────────────────────────────────────────────────────────────
router.get('/drivers', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page, limit, skip } = getPagination(req.query);
    const { is_approved, is_online } = req.query;

    const where: any = {};
    if (is_approved !== undefined) where.is_approved = is_approved === 'true';
    if (is_online !== undefined) where.is_online = is_online === 'true';

    const [drivers, total] = await Promise.all([
      prisma.driver.findMany({
        where,
        include: {
          user: { select: { id: true, name: true, phone: true, email: true, is_active: true } },
          vehicle_type: { select: { name_en: true, name_ar: true } },
        },
        orderBy: { created_at: 'desc' },
        skip,
        take: limit,
      }),
      prisma.driver.count({ where }),
    ]);

    res.json({
      success: true,
      data: drivers,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit), hasMore: page * limit < total },
    });
  } catch (err) {
    next(err);
  }
});

// ─── Approve Driver ───────────────────────────────────────────────────────────
router.put('/drivers/:id/approve', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const driver = await prisma.driver.findUnique({ where: { id: req.params.id } });
    if (!driver) throw createError('Driver not found', 404);

    const updated = await prisma.driver.update({
      where: { id: req.params.id },
      data: { is_approved: true },
    });

    res.json({ success: true, message: 'Driver approved', data: updated });
  } catch (err) {
    next(err);
  }
});

// ─── Payment Reports ──────────────────────────────────────────────────────────
router.get('/payments', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page, limit, skip } = getPagination(req.query);
    const { status, type, from, to } = req.query;

    const where: any = {};
    if (status) where.status = status;
    if (type) where.type = type;
    if (from || to) {
      where.created_at = {};
      if (from) where.created_at.gte = new Date(from as string);
      if (to) where.created_at.lte = new Date(to as string);
    }

    const [payments, total, aggregate] = await Promise.all([
      prisma.payment.findMany({
        where,
        include: {
          user: { select: { id: true, name: true, phone: true } },
          ride: { select: { id: true, pickup_address: true, dropoff_address: true } },
        },
        orderBy: { created_at: 'desc' },
        skip,
        take: limit,
      }),
      prisma.payment.count({ where }),
      prisma.payment.aggregate({ where, _sum: { amount: true } }),
    ]);

    res.json({
      success: true,
      data: payments,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        hasMore: page * limit < total,
        total_amount: aggregate._sum.amount || 0,
      },
    });
  } catch (err) {
    next(err);
  }
});

// ─── Revenue Reports ──────────────────────────────────────────────────────────
router.get('/earnings', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { period = 'month' } = req.query;
    const now = new Date();
    let fromDate: Date;

    switch (period) {
      case 'today': fromDate = new Date(now.getFullYear(), now.getMonth(), now.getDate()); break;
      case 'week': fromDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000); break;
      case 'month': fromDate = new Date(now.getFullYear(), now.getMonth(), 1); break;
      case 'year': fromDate = new Date(now.getFullYear(), 0, 1); break;
      default: fromDate = new Date(now.getFullYear(), now.getMonth(), 1);
    }

    const [completedRides, totalRevenue, topDrivers] = await Promise.all([
      prisma.ride.count({ where: { status: 'COMPLETED', completed_at: { gte: fromDate } } }),
      prisma.ride.aggregate({
        where: { status: 'COMPLETED', completed_at: { gte: fromDate } },
        _sum: { final_price: true, commission_amount: true },
        _avg: { final_price: true },
      }),
      prisma.driver.findMany({
        where: { total_rides: { gt: 0 } },
        include: { user: { select: { name: true } } },
        orderBy: { total_earnings: 'desc' },
        take: 5,
      }),
    ]);

    res.json({
      success: true,
      data: {
        period,
        from: fromDate,
        to: now,
        completed_rides: completedRides,
        gross_revenue: totalRevenue._sum.final_price || 0,
        commission_revenue: totalRevenue._sum.commission_amount || 0,
        avg_ride_value: totalRevenue._avg.final_price || 0,
        top_drivers: topDrivers.map((d) => ({
          name: d.user.name,
          total_rides: d.total_rides,
          total_earnings: d.total_earnings,
          rating: d.rating,
        })),
      },
    });
  } catch (err) {
    next(err);
  }
});

// ─── Create Promo Code ────────────────────────────────────────────────────────
router.post(
  '/promo-codes',
  [
    body('code').trim().toUpperCase().isLength({ min: 3, max: 20 }).withMessage('Code must be 3-20 characters'),
    body('discount_type').isIn(['PERCENTAGE', 'FIXED']).withMessage('Invalid discount type'),
    body('discount_value').isFloat({ min: 0.01 }).withMessage('Discount value must be positive'),
    body('max_uses').isInt({ min: 1 }).withMessage('Max uses must be at least 1'),
    body('valid_from').isISO8601().withMessage('valid_from must be a valid date'),
    body('valid_until').isISO8601().withMessage('valid_until must be a valid date'),
  ],
  validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const existing = await prisma.promoCode.findUnique({ where: { code: req.body.code.toUpperCase() } });
      if (existing) throw createError('Promo code already exists', 409);

      const promo = await prisma.promoCode.create({
        data: {
          code: req.body.code.toUpperCase(),
          discount_type: req.body.discount_type,
          discount_value: req.body.discount_value,
          max_uses: req.body.max_uses,
          valid_from: new Date(req.body.valid_from),
          valid_until: new Date(req.body.valid_until),
          is_active: req.body.is_active ?? true,
        },
      });

      res.status(201).json({ success: true, message: 'Promo code created', data: promo });
    } catch (err) {
      next(err);
    }
  }
);

// ─── List Promo Codes ─────────────────────────────────────────────────────────
router.get('/promo-codes', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page, limit, skip } = getPagination(req.query);
    const [promos, total] = await Promise.all([
      prisma.promoCode.findMany({ orderBy: { created_at: 'desc' }, skip, take: limit }),
      prisma.promoCode.count(),
    ]);
    res.json({
      success: true,
      data: promos,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit), hasMore: page * limit < total },
    });
  } catch (err) {
    next(err);
  }
});

// ─── List Vehicle Types ────────────────────────────────────────────────────────
router.get('/vehicle-types', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const types = await prisma.vehicleType.findMany({ orderBy: { base_fare: 'asc' } });
    res.json({ success: true, data: types });
  } catch (err) {
    next(err);
  }
});

// ─── Create Vehicle Type ──────────────────────────────────────────────────────
router.post(
  '/vehicle-types',
  [
    body('name_ar').trim().notEmpty().withMessage('Arabic name required'),
    body('name_en').trim().notEmpty().withMessage('English name required'),
    body('base_fare').isFloat({ min: 0 }),
    body('per_km').isFloat({ min: 0 }),
    body('per_min').isFloat({ min: 0 }),
    body('min_fare').isFloat({ min: 0 }),
  ],
  validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const vType = await prisma.vehicleType.create({
        data: {
          name_ar: req.body.name_ar,
          name_en: req.body.name_en,
          icon: req.body.icon || 'car',
          base_fare: req.body.base_fare,
          per_km: req.body.per_km,
          per_min: req.body.per_min,
          min_fare: req.body.min_fare,
          is_active: req.body.is_active ?? true,
        },
      });
      res.status(201).json({ success: true, message: 'Vehicle type created', data: vType });
    } catch (err) {
      next(err);
    }
  }
);

export default router;
