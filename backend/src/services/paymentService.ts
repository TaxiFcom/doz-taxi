import { PrismaClient, RideStatus, PaymentStatus, TransactionType, PaymentType } from '@prisma/client';
import { generateReference } from '../utils/helpers';
import { notificationService } from './notificationService';
import { createError } from '../middleware/errorHandler';

const prisma = new PrismaClient();

export const paymentService = {
  async processRidePayment(rideId: string, riderId: string, method: string): Promise<any> {
    const ride = await prisma.ride.findUnique({ where: { id: rideId }, include: { rider: true } });
    if (!ride) throw createError('Ride not found', 404);
    if (ride.rider_id !== riderId) throw createError('Unauthorized', 403);
    if (ride.status !== RideStatus.COMPLETED) throw createError('Ride is not completed', 400);
    if (!ride.final_price) throw createError('Final price not set', 400);
    const reference = generateReference('PAY');
    const existingPayment = await prisma.payment.findFirst({ where: { ride_id: rideId, status: PaymentStatus.COMPLETED } });
    if (existingPayment) throw createError('Ride already paid', 400);
    if (method === 'WALLET') {
      const wallet = await prisma.wallet.findUnique({ where: { user_id: riderId } });
      if (!wallet) throw createError('Wallet not found', 404);
      if (wallet.balance < ride.final_price) throw createError('Insufficient wallet balance', 400);
      const result = await prisma.$transaction(async (tx) => {
        await tx.wallet.update({ where: { user_id: riderId }, data: { balance: { decrement: ride.final_price! } } });
        await tx.walletTransaction.create({ data: { wallet_id: wallet.id, amount: ride.final_price!, type: TransactionType.DEBIT, description: `Ride payment #${rideId.slice(0, 8)}`, reference } });
        const payment = await tx.payment.create({ data: { ride_id: rideId, user_id: riderId, amount: ride.final_price!, type: PaymentType.RIDE_PAYMENT, method: 'WALLET', status: PaymentStatus.COMPLETED, reference } });
        if (ride.driver_id && ride.commission_amount !== null) {
          const driverEarnings = ride.final_price! - (ride.commission_amount || 0);
          await tx.driver.update({ where: { id: ride.driver_id }, data: { total_earnings: { increment: driverEarnings } } });
          const driverUser = await tx.driver.findUnique({ where: { id: ride.driver_id }, select: { user_id: true } });
          if (driverUser) {
            const driverWallet = await tx.wallet.findUnique({ where: { user_id: driverUser.user_id } });
            if (driverWallet) {
              await tx.wallet.update({ where: { id: driverWallet.id }, data: { balance: { increment: driverEarnings } } });
              await tx.walletTransaction.create({ data: { wallet_id: driverWallet.id, amount: driverEarnings, type: TransactionType.CREDIT, description: `Ride earnings #${rideId.slice(0, 8)}`, reference } });
            }
          }
        }
        return payment;
      });
      return result;
    } else {
      const payment = await prisma.payment.create({ data: { ride_id: rideId, user_id: riderId, amount: ride.final_price, type: PaymentType.RIDE_PAYMENT, method: 'CASH', status: PaymentStatus.COMPLETED, reference } });
      if (ride.driver_id) {
        const driverEarnings = ride.final_price - (ride.commission_amount || 0);
        await prisma.driver.update({ where: { id: ride.driver_id }, data: { total_earnings: { increment: driverEarnings } } });
      }
      return payment;
    }
  },

  async topupWallet(userId: string, amount: number, method: string): Promise<any> {
    if (amount <= 0) throw createError('Amount must be positive', 400);
    if (amount > 1000) throw createError('Maximum top-up is 1000 JOD', 400);
    const reference = generateReference('TOP');
    const result = await prisma.$transaction(async (tx) => {
      let wallet = await tx.wallet.findUnique({ where: { user_id: userId } });
      if (!wallet) wallet = await tx.wallet.create({ data: { user_id: userId, balance: 0, currency: 'JOD' } });
      await tx.wallet.update({ where: { id: wallet.id }, data: { balance: { increment: amount } } });
      const txRecord = await tx.walletTransaction.create({ data: { wallet_id: wallet.id, amount, type: TransactionType.CREDIT, description: `Wallet top-up via ${method}`, reference } });
      await tx.payment.create({ data: { user_id: userId, amount, type: PaymentType.WALLET_TOPUP, method, status: PaymentStatus.COMPLETED, reference } });
      return { ...wallet, balance: wallet.balance + amount, transaction: txRecord };
    });
    await notificationService.notifyWalletTopup(userId, amount, reference);
    return result;
  },

  async getWallet(userId: string) {
    let wallet = await prisma.wallet.findUnique({ where: { user_id: userId } });
    if (!wallet) wallet = await prisma.wallet.create({ data: { user_id: userId, balance: 0, currency: 'JOD' } });
    return wallet;
  },

  async getTransactions(userId: string, page: number, limit: number) {
    const wallet = await prisma.wallet.findUnique({ where: { user_id: userId } });
    if (!wallet) return { data: [], meta: { total: 0, page, limit, totalPages: 0, hasMore: false } };
    const skip = (page - 1) * limit;
    const [transactions, total] = await Promise.all([
      prisma.walletTransaction.findMany({ where: { wallet_id: wallet.id }, orderBy: { created_at: 'desc' }, skip, take: limit }),
      prisma.walletTransaction.count({ where: { wallet_id: wallet.id } }),
    ]);
    return { data: transactions, meta: { total, page, limit, totalPages: Math.ceil(total / limit), hasMore: page * limit < total } };
  },
};
