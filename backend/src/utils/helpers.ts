import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import config from '../config';

export const generateAccessToken = (userId: string, role: string): string => {
  return jwt.sign({ userId, role }, config.jwt.secret, { expiresIn: config.jwt.expiresIn as any });
};

export const generateRefreshToken = (userId: string): string => {
  return jwt.sign({ userId }, config.jwt.refreshSecret, { expiresIn: config.jwt.refreshExpiresIn as any });
};

export const verifyRefreshToken = (token: string): { userId: string } | null => {
  try { return jwt.verify(token, config.jwt.refreshSecret) as { userId: string }; } catch { return null; }
};

export const hashPassword = async (password: string): Promise<string> => bcrypt.hash(password, 12);
export const comparePassword = async (password: string, hash: string): Promise<boolean> => bcrypt.compare(password, hash);

export const generateOtp = (length = 6): string => {
  let otp = '';
  for (let i = 0; i < length; i++) otp += Math.floor(Math.random() * 10);
  return otp;
};

export const getOtpForPhone = (_phone: string): string => {
  if (config.env === 'development') return '123456';
  return generateOtp();
};

export const newId = (): string => uuidv4();

export const addMinutes = (date: Date, minutes: number): Date => new Date(date.getTime() + minutes * 60 * 1000);
export const addDays = (date: Date, days: number): Date => new Date(date.getTime() + days * 24 * 60 * 60 * 1000);

export const getPagination = (query: any): { page: number; limit: number; skip: number } => {
  const page = Math.max(1, parseInt(query.page || '1', 10));
  const limit = Math.min(100, Math.max(1, parseInt(query.limit || '20', 10)));
  const skip = (page - 1) * limit;
  return { page, limit, skip };
};

export const paginate = <T>(data: T[], total: number, page: number, limit: number) => ({
  data,
  meta: { total, page, limit, totalPages: Math.ceil(total / limit), hasMore: page * limit < total },
});

export const successResponse = (res: any, data: any, message = 'Success', statusCode = 200) =>
  res.status(statusCode).json({ success: true, message, data });

export const errorResponse = (res: any, message: string, statusCode = 400, errors?: any) =>
  res.status(statusCode).json({ success: false, message, ...(errors && { errors }) });

export const generateReference = (prefix = 'DOZ'): string => {
  const timestamp = Date.now().toString(36).toUpperCase();
  const random = Math.random().toString(36).substring(2, 6).toUpperCase();
  return `${prefix}-${timestamp}-${random}`;
};

export const maskPhone = (phone: string): string => {
  if (phone.length <= 4) return phone;
  return phone.slice(0, -4).replace(/\d/g, '*') + phone.slice(-4);
};
