import dotenv from 'dotenv';
dotenv.config();

export const config = {
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '3000', 10),
  databaseUrl: process.env.DATABASE_URL || 'file:./dev.db',

  jwt: {
    secret: process.env.JWT_SECRET || 'doz-secret-key-change-in-production',
    refreshSecret: process.env.JWT_REFRESH_SECRET || 'doz-refresh-secret-change-in-production',
    expiresIn: process.env.JWT_EXPIRES_IN || '15m',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  },

  otp: {
    expiryMinutes: parseInt(process.env.OTP_EXPIRY_MINUTES || '5', 10),
  },

  upload: {
    dir: process.env.UPLOAD_DIR || './uploads',
    maxFileSizeMb: parseInt(process.env.MAX_FILE_SIZE_MB || '5', 10),
  },

  app: {
    name: process.env.APP_NAME || 'DOZ',
    frontendUrl: process.env.FRONTEND_URL || 'http://localhost:3001',
  },

  commission: {
    defaultRate: parseFloat(process.env.DEFAULT_COMMISSION_RATE || '0.15'),
  },
};

export default config;
