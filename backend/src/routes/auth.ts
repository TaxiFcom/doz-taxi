import { Router, Request, Response, NextFunction } from 'express';
import { body } from 'express-validator';
import { PrismaClient } from '@prisma/client';
import { validate } from '../middleware/validate';
import { authenticate } from '../middleware/auth';
import { hashPassword, comparePassword, generateAccessToken, generateRefreshToken, verifyRefreshToken, getOtpForPhone, addMinutes, addDays } from '../utils/helpers';
import { createError } from '../middleware/errorHandler';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import config from '../config';

const router = Router();
const prisma = new PrismaClient();

const avatarStorage = multer.diskStorage({
  destination: (req, file, cb) => { const dir = path.join(config.upload.dir, 'avatars'); fs.mkdirSync(dir, { recursive: true }); cb(null, dir); },
  filename: (req, file, cb) => { const ext = path.extname(file.originalname); cb(null, `${req.user!.id}-${Date.now()}${ext}`); },
});

const upload = multer({
  storage: avatarStorage,
  limits: { fileSize: config.upload.maxFileSizeMb * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = /jpeg|jpg|png|webp/;
    if (allowed.test(path.extname(file.originalname).toLowerCase())) { cb(null, true); }
    else { cb(new Error('Only image files are allowed')); }
  },
});

// Register
router.post('/register',
  [body('name').trim().isLength({ min: 2, max: 100 }), body('phone').trim().isMobilePhone('any'), body('email').optional().isEmail().normalizeEmail(), body('password').optional().isLength({ min: 6 }), body('role').optional().isIn(['RIDER', 'DRIVER']), body('lang').optional().isIn(['ar', 'en'])],
  validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { name, phone, email, password, role = 'RIDER', lang = 'ar' } = req.body;
      const existing = await prisma.user.findUnique({ where: { phone } });
      if (existing) throw createError('Phone number already registered', 409);
      if (email) { const emailExists = await prisma.user.findUnique({ where: { email } }); if (emailExists) throw createError('Email already registered', 409); }
      const password_hash = password ? await hashPassword(password) : null;
      const user = await prisma.user.create({ data: { name, phone, email, password_hash, role, lang }, select: { id: true, name: true, phone: true, email: true, role: true, lang: true, created_at: true } });
      await prisma.wallet.create({ data: { user_id: user.id, balance: 0, currency: 'JOD' } });
      if (role === 'DRIVER' && req.body.license_number) {
        await prisma.driver.create({ data: { user_id: user.id, license_number: req.body.license_number, vehicle_model: req.body.vehicle_model || '', vehicle_color: req.body.vehicle_color || '', plate_number: req.body.plate_number || '', commission_rate: config.commission.defaultRate } });
      }
      const accessToken = generateAccessToken(user.id, user.role);
      const refreshToken = generateRefreshToken(user.id);
      await prisma.refreshToken.create({ data: { user_id: user.id, token: refreshToken, expires_at: addDays(new Date(), 7) } });
      res.status(201).json({ success: true, message: 'Registration successful', data: { user, access_token: accessToken, refresh_token: refreshToken } });
    } catch (err) { next(err); }
  }
);

// Send OTP
router.post('/send-otp', [body('phone').trim().isMobilePhone('any')], validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { phone } = req.body;
      const otp = getOtpForPhone(phone);
      const expiresAt = addMinutes(new Date(), config.otp.expiryMinutes);
      await prisma.otp.updateMany({ where: { phone, is_used: false }, data: { is_used: true } });
      const user = await prisma.user.findUnique({ where: { phone } });
      await prisma.otp.create({ data: { phone, code: otp, expires_at: expiresAt, user_id: user?.id || null } });
      const responseData: any = { message: 'OTP sent successfully' };
      if (config.env === 'development') { responseData.otp = otp; responseData.note = 'OTP returned in dev mode only'; }
      res.json({ success: true, data: responseData });
    } catch (err) { next(err); }
  }
);

// Verify OTP
router.post('/verify-otp', [body('phone').trim().isMobilePhone('any'), body('code').trim().isLength({ min: 4, max: 8 })], validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { phone, code } = req.body;
      const otp = await prisma.otp.findFirst({ where: { phone, code, is_used: false, expires_at: { gt: new Date() } }, orderBy: { created_at: 'desc' } });
      if (!otp) throw createError('Invalid or expired OTP', 400);
      await prisma.otp.update({ where: { id: otp.id }, data: { is_used: true } });
      let user = await prisma.user.findUnique({ where: { phone } });
      let isNew = false;
      if (!user) { user = await prisma.user.create({ data: { name: phone, phone, is_verified: true } }); await prisma.wallet.create({ data: { user_id: user.id, balance: 0, currency: 'JOD' } }); isNew = true; }
      else { await prisma.user.update({ where: { id: user.id }, data: { is_verified: true } }); }
      const accessToken = generateAccessToken(user.id, user.role);
      const refreshToken = generateRefreshToken(user.id);
      await prisma.refreshToken.create({ data: { user_id: user.id, token: refreshToken, expires_at: addDays(new Date(), 7) } });
      res.json({ success: true, message: isNew ? 'Account created and verified' : 'OTP verified', data: { user: { id: user.id, name: user.name, phone: user.phone, role: user.role, is_new: isNew }, access_token: accessToken, refresh_token: refreshToken } });
    } catch (err) { next(err); }
  }
);

// Login
router.post('/login', [body('phone').optional().trim().isMobilePhone('any'), body('email').optional().isEmail().normalizeEmail(), body('password').optional().isLength({ min: 1 })], validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { phone, email, password } = req.body;
      if (!phone && !email) throw createError('Phone or email required', 400);
      let user: any;
      if (email && password) {
        user = await prisma.user.findUnique({ where: { email } });
        if (!user || !user.password_hash) throw createError('Invalid credentials', 401);
        const valid = await comparePassword(password, user.password_hash);
        if (!valid) throw createError('Invalid credentials', 401);
      } else if (phone && password) {
        user = await prisma.user.findUnique({ where: { phone } });
        if (!user || !user.password_hash) throw createError('Invalid credentials', 401);
        const valid = await comparePassword(password, user.password_hash);
        if (!valid) throw createError('Invalid credentials', 401);
      } else { throw createError('Password required for email/phone login', 400); }
      if (!user.is_active) throw createError('Account is deactivated', 403);
      const accessToken = generateAccessToken(user.id, user.role);
      const refreshToken = generateRefreshToken(user.id);
      await prisma.refreshToken.create({ data: { user_id: user.id, token: refreshToken, expires_at: addDays(new Date(), 7) } });
      res.json({ success: true, message: 'Login successful', data: { user: { id: user.id, name: user.name, phone: user.phone, email: user.email, role: user.role, lang: user.lang }, access_token: accessToken, refresh_token: refreshToken } });
    } catch (err) { next(err); }
  }
);

// Refresh Token
router.post('/refresh-token', [body('refresh_token').notEmpty()], validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { refresh_token } = req.body;
      const decoded = verifyRefreshToken(refresh_token);
      if (!decoded) throw createError('Invalid or expired refresh token', 401);
      const stored = await prisma.refreshToken.findUnique({ where: { token: refresh_token } });
      if (!stored || stored.expires_at < new Date()) throw createError('Refresh token expired', 401);
      const user = await prisma.user.findUnique({ where: { id: decoded.userId } });
      if (!user || !user.is_active) throw createError('User not found or inactive', 401);
      await prisma.refreshToken.delete({ where: { token: refresh_token } });
      const newAccessToken = generateAccessToken(user.id, user.role);
      const newRefreshToken = generateRefreshToken(user.id);
      await prisma.refreshToken.create({ data: { user_id: user.id, token: newRefreshToken, expires_at: addDays(new Date(), 7) } });
      res.json({ success: true, data: { access_token: newAccessToken, refresh_token: newRefreshToken } });
    } catch (err) { next(err); }
  }
);

// Get Current User
router.get('/me', authenticate, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await prisma.user.findUnique({ where: { id: req.user!.id }, include: { driver: { include: { vehicle_type: true } }, wallet: { select: { balance: true, currency: true } } } });
    if (!user) throw createError('User not found', 404);
    const { password_hash, ...safeUser } = user as any;
    res.json({ success: true, data: safeUser });
  } catch (err) { next(err); }
});

// Update Profile
router.put('/me', authenticate,
  [body('name').optional().trim().isLength({ min: 2, max: 100 }), body('email').optional().isEmail().normalizeEmail(), body('lang').optional().isIn(['ar', 'en']), body('password').optional().isLength({ min: 6 })],
  validate,
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { name, email, lang, password } = req.body;
      const updateData: any = {};
      if (name) updateData.name = name;
      if (lang) updateData.lang = lang;
      if (email) { const existing = await prisma.user.findFirst({ where: { email, id: { not: req.user!.id } } }); if (existing) throw createError('Email already in use', 409); updateData.email = email; }
      if (password) { updateData.password_hash = await hashPassword(password); }
      const user = await prisma.user.update({ where: { id: req.user!.id }, data: updateData, select: { id: true, name: true, phone: true, email: true, role: true, lang: true, avatar_url: true } });
      res.json({ success: true, message: 'Profile updated', data: user });
    } catch (err) { next(err); }
  }
);

// Upload Avatar
router.post('/me/avatar', authenticate, upload.single('avatar'),
  async (req: Request, res: Response, next: NextFunction) => {
    try {
      if (!req.file) throw createError('No file uploaded', 400);
      const avatarUrl = `/uploads/avatars/${req.file.filename}`;
      await prisma.user.update({ where: { id: req.user!.id }, data: { avatar_url: avatarUrl } });
      res.json({ success: true, message: 'Avatar updated', data: { avatar_url: avatarUrl } });
    } catch (err) { next(err); }
  }
);

export default router;
