import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth';
import { createError } from '../middleware/errorHandler';
import { getPagination } from '../utils/helpers';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

router.get('/', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { page, limit, skip } = getPagination(req.query);
    const [notifications, total, unreadCount] = await Promise.all([
      prisma.notification.findMany({
        where: { user_id: req.user!.id },
        orderBy: { created_at: 'desc' },
        skip,
        take: limit,
      }),
      prisma.notification.count({ where: { user_id: req.user!.id } }),
      prisma.notification.count({ where: { user_id: req.user!.id, is_read: false } }),
    ]);
    res.json({
      success: true,
      data: notifications.map((n) => ({ ...n, data: n.data_json ? JSON.parse(n.data_json) : null })),
      meta: { total, page, limit, totalPages: Math.ceil(total / limit), hasMore: page * limit < total, unread_count: unreadCount },
    });
  } catch (err) { next(err); }
});

router.put('/:id/read', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const notification = await prisma.notification.findUnique({ where: { id: req.params.id } });
    if (!notification) throw createError('Notification not found', 404);
    if (notification.user_id !== req.user!.id) throw createError('Unauthorized', 403);
    await prisma.notification.update({ where: { id: req.params.id }, data: { is_read: true } });
    res.json({ success: true, message: 'Notification marked as read' });
  } catch (err) { next(err); }
});

router.put('/read-all', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const result = await prisma.notification.updateMany({
      where: { user_id: req.user!.id, is_read: false },
      data: { is_read: true },
    });
    res.json({ success: true, message: `${result.count} notifications marked as read`, data: { count: result.count } });
  } catch (err) { next(err); }
});

export default router;
