import 'dotenv/config';
import express from 'express';
import http from 'http';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import path from 'path';
import fs from 'fs';

import config from './config';
import { errorHandler, notFound } from './middleware/errorHandler';
import { setupWebSocket } from './ws/handler';

// Routes
import authRouter from './routes/auth';
import ridesRouter from './routes/rides';
import bidsRouter from './routes/bids';
import driversRouter from './routes/drivers';
import paymentsRouter from './routes/payments';
import notificationsRouter from './routes/notifications';
import adminRouter from './routes/admin';
import { PrismaClient } from '@prisma/client';

const app = express();
const server = http.createServer(app);
const prisma = new PrismaClient();

// ─── Ensure Upload Directories Exist ─────────────────────────────────────────────
fs.mkdirSync(path.join(config.upload.dir, 'avatars'), { recursive: true });

// ─── Security & Request Parsing ─────────────────────────────────────────────────
app.use(helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' },
}));
app.use(cors({
  origin: config.app.frontendUrl,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ─── Logging ────────────────────────────────────────────────────────────────────────────
if (config.env !== 'test') {
  app.use(morgan(config.env === 'production' ? 'combined' : 'dev'));
}

// ─── Static Files ──────────────────────────────────────────────────────────────────────
app.use('/uploads', express.static(path.resolve(config.upload.dir)));

// ─── Health Check ─────────────────────────────────────────────────────────────────────
app.get('/health', async (req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.json({
      status: 'ok',
      env: config.env,
      db: 'connected',
      ts: new Date().toISOString(),
    });
  } catch (err) {
    res.status(503).json({ status: 'error', db: 'disconnected' });
  }
});

// ─── API Info ────────────────────────────────────────────────────────────────────────────
app.get('/api/v1', (req, res) => {
  res.json({
    name: 'DOZ Ride-Hailing API',
    version: '1.0.0',
    docs: '/api/v1/docs',
    endpoints: {
      auth: '/api/v1/auth',
      rides: '/api/v1/rides',
      bids: '/api/v1/bids',
      drivers: '/api/v1/drivers',
      payments: '/api/v1/payments',
      notifications: '/api/v1/notifications',
      admin: '/api/v1/admin',
    },
  });
});

// ─── Vehicle Types (Public) ─────────────────────────────────────────────────────────
app.get('/api/v1/vehicle-types', async (req, res, next) => {
  try {
    const types = await prisma.vehicleType.findMany({ where: { is_active: true }, orderBy: { base_fare: 'asc' } });
    res.json({ success: true, data: types });
  } catch (err) {
    next(err);
  }
});

// ─── Promo Code Validation (Public) ───────────────────────────────────────────────────
app.post('/api/v1/promo-codes/validate', express.json(), async (req, res, next) => {
  try {
    const { code } = req.body;
    if (!code) {
      res.status(400).json({ success: false, message: 'Code required' });
      return;
    }
    const promo = await prisma.promoCode.findUnique({ where: { code: code.toUpperCase() } });
    if (!promo || !promo.is_active || promo.valid_until < new Date() || promo.current_uses >= promo.max_uses) {
      res.status(404).json({ success: false, message: 'Promo code not valid or expired' });
      return;
    }
    res.json({ success: true, data: { code: promo.code, discount_type: promo.discount_type, discount_value: promo.discount_value } });
  } catch (err) {
    next(err);
  }
});

// ─── API Routes ───────────────────────────────────────────────────────────────────────────
app.use('/api/v1/auth', authRouter);
app.use('/api/v1/rides', ridesRouter);
app.use('/api/v1/bids', bidsRouter);
app.use('/api/v1/drivers', driversRouter);
app.use('/api/v1/payments', paymentsRouter);
app.use('/api/v1/notifications', notificationsRouter);
app.use('/api/v1/admin', adminRouter);

// ─── 404 & Error Handler ─────────────────────────────────────────────────────────────
app.use(notFound);
app.use(errorHandler);

// ─── WebSocket Setup ─────────────────────────────────────────────────────────────────────
const wss = setupWebSocket(server);

// ─── Graceful Shutdown ───────────────────────────────────────────────────────────────────
const shutdown = async (signal: string) => {
  console.log(`\n[Server] Received ${signal}. Graceful shutdown...`);
  await prisma.$disconnect();
  server.close(() => {
    console.log('[Server] HTTP server closed');
    process.exit(0);
  });
  setTimeout(() => process.exit(1), 10000);
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
process.on('uncaughtException', (err) => {
  console.error('[Server] Uncaught Exception:', err);
  shutdown('uncaughtException');
});
process.on('unhandledRejection', (reason) => {
  console.error('[Server] Unhandled Rejection:', reason);
});

// ─── Start Server ───────────────────────────────────────────────────────────────────────────
server.listen(config.port, '0.0.0.0', () => {
  console.log(`DOZ Backend API started on port ${config.port}`);
});

export { app, server, wss };
