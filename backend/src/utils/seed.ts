/**
 * DOZ Database Seeder
 * Run: npx ts-node src/utils/seed.ts
 * Creates demo data for development and testing.
 */

import 'dotenv/config';
import { PrismaClient, RideStatus, BidStatus, PaymentMethod, PaymentStatus, TransactionType, PaymentType, DiscountType } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function hashPassword(pwd: string): Promise<string> {
  return bcrypt.hash(pwd, 12);
}

async function main() {
  console.log('🌱 Seeding DOZ database...\n');

  // ─── Cleanup ──────────────────────────────────────────────────────────────────────
  await prisma.walletTransaction.deleteMany();
  await prisma.wallet.deleteMany();
  await prisma.refreshToken.deleteMany();
  await prisma.otp.deleteMany();
  await prisma.notification.deleteMany();
  await prisma.rating.deleteMany();
  await prisma.payment.deleteMany();
  await prisma.bid.deleteMany();
  await prisma.supportTicket.deleteMany();
  await prisma.ride.deleteMany();
  await prisma.driver.deleteMany();
  await prisma.promoCode.deleteMany();
  await prisma.vehicleType.deleteMany();
  await prisma.user.deleteMany();

  console.log('✓ Cleaned existing data');

  // ─── Vehicle Types ───────────────────────────────────────────────────────────────────
  const [economy, comfort, premium, lux] = await Promise.all([
    prisma.vehicleType.create({
      data: { name_ar: '\u0627\u0642\u062a\u0635\u0627\u062f\u064a', name_en: 'Economy', icon: 'car', base_fare: 1.5, per_km: 0.35, per_min: 0.08, min_fare: 2.5 },
    }),
    prisma.vehicleType.create({
      data: { name_ar: '\u0645\u0631\u064a\u062d', name_en: 'Comfort', icon: 'car_comfort', base_fare: 2.0, per_km: 0.45, per_min: 0.10, min_fare: 3.0 },
    }),
    prisma.vehicleType.create({
      data: { name_ar: '\u0628\u0631\u064a\u0645\u064a\u0645', name_en: 'Premium', icon: 'car_premium', base_fare: 3.0, per_km: 0.65, per_min: 0.15, min_fare: 4.5 },
    }),
    prisma.vehicleType.create({
      data: { name_ar: '\u0644\u0648\u0643\u0633', name_en: 'Lux', icon: 'car_lux', base_fare: 5.0, per_km: 1.00, per_min: 0.25, min_fare: 8.0 },
    }),
  ]);
  console.log('✓ Created 4 vehicle types');

  // ─── Admin User ─────────────────────────────────────────────────────────────────────
  const admin = await prisma.user.create({
    data: {
      name: 'Admin DOZ',
      email: 'admin@doz.com',
      phone: '+962790000001',
      password_hash: await hashPassword('admin123'),
      role: 'ADMIN',
      lang: 'ar',
      is_active: true,
      is_verified: true,
    },
  });
  await prisma.wallet.create({ data: { user_id: admin.id, balance: 0, currency: 'JOD' } });
  console.log(`✓ Admin: admin@doz.com / admin123`);

  // ─── Rider Users ────────────────────────────────────────────────────────────────────
  const rider1 = await prisma.user.create({
    data: {
      name: '\u0623\u062d\u0645\u062f \u0645\u062d\u0645\u062f',
      email: 'ahmed@example.com',
      phone: '+962791000001',
      password_hash: await hashPassword('rider123'),
      role: 'RIDER',
      lang: 'ar',
      is_active: true,
      is_verified: true,
    },
  });

  const rider2 = await prisma.user.create({
    data: {
      name: 'Sara Johnson',
      email: 'sara@example.com',
      phone: '+962791000002',
      password_hash: await hashPassword('rider123'),
      role: 'RIDER',
      lang: 'en',
      is_active: true,
      is_verified: true,
    },
  });

  const rider3 = await prisma.user.create({
    data: {
      name: '\u0645\u062d\u0645\u062f \u0639\u0644\u064a',
      email: 'mohammad@example.com',
      phone: '+962791000003',
      password_hash: await hashPassword('rider123'),
      role: 'RIDER',
      lang: 'ar',
      is_active: true,
      is_verified: true,
    },
  });

  // Create wallets for riders
  const wallet1 = await prisma.wallet.create({ data: { user_id: rider1.id, balance: 25.50, currency: 'JOD' } });
  const wallet2 = await prisma.wallet.create({ data: { user_id: rider2.id, balance: 50.00, currency: 'JOD' } });
  const wallet3 = await prisma.wallet.create({ data: { user_id: rider3.id, balance: 10.00, currency: 'JOD' } });

  // Add wallet transactions
  await prisma.walletTransaction.createMany({
    data: [
      { wallet_id: wallet1.id, amount: 30.00, type: TransactionType.CREDIT, description: 'Initial top-up', reference: 'TOP-SEED-001' },
      { wallet_id: wallet1.id, amount: 4.50, type: TransactionType.DEBIT, description: 'Ride payment', reference: 'PAY-SEED-001' },
      { wallet_id: wallet2.id, amount: 50.00, type: TransactionType.CREDIT, description: 'Initial top-up', reference: 'TOP-SEED-002' },
      { wallet_id: wallet3.id, amount: 10.00, type: TransactionType.CREDIT, description: 'Initial top-up', reference: 'TOP-SEED-003' },
    ],
  });

  console.log(`✓ Created 3 riders`);

  // ─── Driver Users ────────────────────────────────────────────────────────────────────
  const driverUser1 = await prisma.user.create({
    data: {
      name: '\u062e\u0627\u0644\u062f \u0627\u0644\u0639\u0628\u062f\u0627\u0644\u0644\u0647',
      email: 'khalid.driver@example.com',
      phone: '+962792000001',
      password_hash: await hashPassword('driver123'),
      role: 'DRIVER',
      lang: 'ar',
      is_active: true,
      is_verified: true,
    },
  });

  const driverUser2 = await prisma.user.create({
    data: {
      name: 'Omar Hassan',
      email: 'omar.driver@example.com',
      phone: '+962792000002',
      password_hash: await hashPassword('driver123'),
      role: 'DRIVER',
      lang: 'en',
      is_active: true,
      is_verified: true,
    },
  });

  const driverUser3 = await prisma.user.create({
    data: {
      name: '\u0633\u0627\u0645\u064a \u0627\u0644\u0631\u0634\u064a\u062f',
      email: 'sami.driver@example.com',
      phone: '+962792000003',
      password_hash: await hashPassword('driver123'),
      role: 'DRIVER',
      lang: 'ar',
      is_active: true,
      is_verified: true,
    },
  });

  // Create driver profiles
  const driver1 = await prisma.driver.create({
    data: {
      user_id: driverUser1.id,
      license_number: 'DL-2024-001',
      vehicle_type_id: comfort.id,
      vehicle_model: 'Toyota Corolla 2022',
      vehicle_color: 'White',
      plate_number: 'A-12345',
      lat: 31.9600,
      lng: 35.9400,
      heading: 90,
      is_online: true,
      is_busy: false,
      rating: 4.8,
      total_rides: 247,
      total_earnings: 1850.50,
      commission_rate: 0.15,
      is_approved: true,
    },
  });

  const driver2 = await prisma.driver.create({
    data: {
      user_id: driverUser2.id,
      license_number: 'DL-2024-002',
      vehicle_type_id: economy.id,
      vehicle_model: 'Kia Cerato 2021',
      vehicle_color: 'Silver',
      plate_number: 'B-67890',
      lat: 31.9650,
      lng: 35.9450,
      heading: 180,
      is_online: true,
      is_busy: false,
      rating: 4.6,
      total_rides: 183,
      total_earnings: 1230.75,
      commission_rate: 0.15,
      is_approved: true,
    },
  });

  const driver3 = await prisma.driver.create({
    data: {
      user_id: driverUser3.id,
      license_number: 'DL-2024-003',
      vehicle_type_id: premium.id,
      vehicle_model: 'BMW 520i 2023',
      vehicle_color: 'Black',
      plate_number: 'C-11111',
      lat: 31.9700,
      lng: 35.9500,
      heading: 270,
      is_online: false,
      is_busy: false,
      rating: 5.0,
      total_rides: 89,
      total_earnings: 3200.00,
      commission_rate: 0.12,
      is_approved: true,
    },
  });

  // Create driver wallets
  const dWallet1 = await prisma.wallet.create({ data: { user_id: driverUser1.id, balance: 145.30, currency: 'JOD' } });
  const dWallet2 = await prisma.wallet.create({ data: { user_id: driverUser2.id, balance: 89.50, currency: 'JOD' } });
  const dWallet3 = await prisma.wallet.create({ data: { user_id: driverUser3.id, balance: 320.00, currency: 'JOD' } });

  console.log(`✓ Created 3 drivers`);

  // ─── Promo Codes ────────────────────────────────────────────────────────────────────
  await prisma.promoCode.createMany({
    data: [
      {
        code: 'WELCOME10',
        discount_type: DiscountType.PERCENTAGE,
        discount_value: 10,
        max_uses: 1000,
        current_uses: 45,
        valid_from: new Date('2024-01-01'),
        valid_until: new Date('2025-12-31'),
        is_active: true,
      },
      {
        code: 'DOZ5OFF',
        discount_type: DiscountType.FIXED,
        discount_value: 0.5,
        max_uses: 500,
        current_uses: 12,
        valid_from: new Date('2024-06-01'),
        valid_until: new Date('2025-06-30'),
        is_active: true,
      },
      {
        code: 'SUMMER20',
        discount_type: DiscountType.PERCENTAGE,
        discount_value: 20,
        max_uses: 200,
        current_uses: 200,
        valid_from: new Date('2024-06-01'),
        valid_until: new Date('2024-08-31'),
        is_active: false,
      },
    ],
  });
  console.log('✓ Created 3 promo codes');

  // ─── Sample Rides ───────────────────────────────────────────────────────────────────

  // Ride 1: Completed (rider1 + driver1)
  const ride1 = await prisma.ride.create({
    data: {
      rider_id: rider1.id,
      driver_id: driver1.id,
      status: RideStatus.COMPLETED,
      pickup_lat: 31.9566,
      pickup_lng: 35.9458,
      pickup_address: '\u0645\u062c\u0645\u0639 \u0627\u0644\u0634\u0628\u0631\u0629\u060c \u0639\u0645\u0651\u0627\u0646',
      dropoff_lat: 31.9816,
      dropoff_lng: 35.9120,
      dropoff_address: '\u0627\u0644\u062c\u0627\u0645\u0639\u0629 \u0627\u0644\u0623\u0631\u062f\u0646\u064a\u0629\u060c \u0639\u0645\u0651\u0627\u0646',
      suggested_price: 4.50,
      final_price: 4.20,
      distance_km: 7.5,
      duration_min: 18,
      commission_amount: 0.63,
      payment_method: PaymentMethod.WALLET,
      rated_by_rider: true,
      rated_by_driver: true,
      started_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
      completed_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000 + 18 * 60 * 1000),
      vehicle_type_id: comfort.id,
    },
  });

  // Ride 2: Completed (rider2 + driver2)
  const ride2 = await prisma.ride.create({
    data: {
      rider_id: rider2.id,
      driver_id: driver2.id,
      status: RideStatus.COMPLETED,
      pickup_lat: 31.9726,
      pickup_lng: 35.8848,
      pickup_address: '\u0648\u0633\u0637 \u0627\u0644\u0628\u0644\u062f\u060c \u0639\u0645\u0651\u0627\u0646',
      dropoff_lat: 31.9454,
      dropoff_lng: 35.9261,
      dropoff_address: '\u0645\u0633\u062a\u0634\u0641\u0649 \u0627\u0644\u0623\u0631\u062f\u0646',
      suggested_price: 3.80,
      final_price: 3.50,
      distance_km: 6.2,
      duration_min: 15,
      commission_amount: 0.525,
      payment_method: PaymentMethod.CASH,
      rated_by_rider: true,
      rated_by_driver: false,
      started_at: new Date(Date.now() - 24 * 60 * 60 * 1000),
      completed_at: new Date(Date.now() - 24 * 60 * 60 * 1000 + 15 * 60 * 1000),
      vehicle_type_id: economy.id,
    },
  });

  // Ride 3: In Progress (rider3 + driver1)
  const ride3 = await prisma.ride.create({
    data: {
      rider_id: rider3.id,
      driver_id: driver1.id,
      status: RideStatus.IN_PROGRESS,
      pickup_lat: 31.9620,
      pickup_lng: 35.9300,
      pickup_address: '\u062f\u0648\u0627\u0631 \u0627\u0644\u062f\u0627\u062e\u0644\u064a\u0629\u060c \u0639\u0645\u0651\u0627\u0646',
      dropoff_lat: 32.0000,
      dropoff_lng: 36.0000,
      dropoff_address: '\u0645\u0637\u0627\u0631 \u0627\u0644\u0645\u0644\u0643\u0629 \u0639\u0644\u064a\u0627\u0621 \u0627\u0644\u062f\u0648\u0644\u064a',
      suggested_price: 12.00,
      final_price: 12.00,
      distance_km: 35.0,
      duration_min: 45,
      commission_amount: 1.80,
      payment_method: PaymentMethod.CASH,
      rated_by_rider: false,
      rated_by_driver: false,
      started_at: new Date(Date.now() - 10 * 60 * 1000),
      vehicle_type_id: comfort.id,
    },
  });

  // Update driver1 as busy
  await prisma.driver.update({ where: { id: driver1.id }, data: { is_busy: true } });

  // Ride 4: Pending (rider1 - waiting for bids)
  const ride4 = await prisma.ride.create({
    data: {
      rider_id: rider1.id,
      status: RideStatus.BIDDING,
      pickup_lat: 31.9820,
      pickup_lng: 35.9100,
      pickup_address: '\u0627\u0644\u062c\u0627\u0645\u0639\u0629 \u0627\u0644\u0623\u0631\u062f\u0646\u064a\u0629',
      dropoff_lat: 31.9500,
      dropoff_lng: 35.8900,
      dropoff_address: '\u0627\u0644\u0631\u0627\u0628\u064a\u0629\u060c \u0639\u0645\u0651\u0627\u0646',
      suggested_price: 5.50,
      distance_km: 9.0,
      duration_min: 22,
      payment_method: PaymentMethod.CASH,
      vehicle_type_id: economy.id,
    },
  });

  // Add bid on ride4 from driver2
  await prisma.bid.create({
    data: {
      ride_id: ride4.id,
      driver_id: driver2.id,
      amount: 5.00,
      status: BidStatus.PENDING,
      note: '\u0633\u0623\u0635\u0644 \u062e\u0644\u0627\u0644 5 \u062f\u0642\u0627\u0626\u0642',
      eta_min: 5,
    },
  });

  // Ride 5: Cancelled
  const ride5 = await prisma.ride.create({
    data: {
      rider_id: rider2.id,
      status: RideStatus.CANCELLED,
      pickup_lat: 31.9400,
      pickup_lng: 35.9200,
      pickup_address: '\u0645\u064a\u062f\u0627\u0646 \u0627\u0644\u0642\u062f\u0633\u060c \u0639\u0645\u0651\u0627\u0646',
      dropoff_lat: 31.9700,
      dropoff_lng: 35.9000,
      dropoff_address: '\u0634\u0627\u0631\u0639 \u0627\u0644\u0645\u062f\u064a\u0646\u0629 \u0627\u0644\u0645\u0646\u0648\u0631\u0629',
      payment_method: PaymentMethod.CASH,
      cancelled_at: new Date(Date.now() - 3 * 60 * 60 * 1000),
      cancel_reason: '\u062a\u063a\u064a\u064a\u0631 \u0627\u0644\u062e\u0637\u0637',
      vehicle_type_id: economy.id,
    },
  });

  console.log('✓ Created 5 sample rides');

  // ─── Ratings ────────────────────────────────────────────────────────────────────────
  await prisma.rating.createMany({
    data: [
      // Rider rates driver for ride1
      {
        ride_id: ride1.id,
        from_user_id: rider1.id,
        to_user_id: driverUser1.id,
        stars: 5,
        tags: 'punctual,friendly,clean_car',
        comment: '\u0645\u0645\u062a\u0627\u0632 \u062c\u062f\u0627\u064b\u060c \u0633\u0627\u0626\u0642 \u0645\u062d\u062a\u0631\u0641',
      },
      // Driver rates rider for ride1
      {
        ride_id: ride1.id,
        from_user_id: driverUser1.id,
        to_user_id: rider1.id,
        stars: 5,
        comment: '\u0631\u0627\u0643\u0628 \u0631\u0627\u0626\u0639',
      },
      // Rider rates driver for ride2
      {
        ride_id: ride2.id,
        from_user_id: rider2.id,
        to_user_id: driverUser2.id,
        stars: 4,
        tags: 'on_time',
        comment: 'Good driver',
      },
    ],
  });
  console.log('✓ Created 3 ratings');

  // ─── Payments ──────────────────────────────────────────────────────────────────────
  await prisma.payment.createMany({
    data: [
      {
        ride_id: ride1.id,
        user_id: rider1.id,
        amount: 4.20,
        type: PaymentType.RIDE_PAYMENT,
        method: 'WALLET',
        status: PaymentStatus.COMPLETED,
        reference: 'PAY-SEED-001',
      },
      {
        ride_id: ride2.id,
        user_id: rider2.id,
        amount: 3.50,
        type: PaymentType.RIDE_PAYMENT,
        method: 'CASH',
        status: PaymentStatus.COMPLETED,
        reference: 'PAY-SEED-002',
      },
    ],
  });
  console.log('✓ Created 2 payments');

  // ─── Notifications ──────────────────────────────────────────────────────────────────
  await prisma.notification.createMany({
    data: [
      {
        user_id: rider1.id,
        title_ar: '\u0645\u0631\u062d\u0628\u0627\u064b \u0628\u0643 \u0641\u064a DOZ',
        title_en: 'Welcome to DOZ',
        body_ar: '\u0627\u0628\u062f\u0623 \u0631\u062d\u0644\u062a\u0643 \u0627\u0644\u0623\u0648\u0644\u0649 \u0627\u0644\u0622\u0646!',
        body_en: 'Start your first ride now!',
        type: 'WELCOME',
        is_read: true,
      },
      {
        user_id: rider1.id,
        title_ar: '\u0627\u0643\u062a\u0645\u0644\u062a \u0627\u0644\u0631\u062d\u0644\u0629',
        title_en: 'Ride Completed',
        body_ar: '\u062a\u0645 \u0625\u062a\u0645\u0627\u0645 \u0631\u062d\u0644\u062a\u0643 \u0628\u0646\u062c\u0627\u062d. \u0627\u0644\u0645\u0628\u0644\u063a: 4.20 \u062f.\u0623',
        body_en: 'Your ride is complete. Amount: 4.20 JOD',
        type: 'RIDE_COMPLETED',
        data_json: JSON.stringify({ rideId: ride1.id, amount: 4.20 }),
        is_read: false,
      },
      {
        user_id: driverUser1.id,
        title_ar: '\u0637\u0644\u0628 \u0631\u062d\u0644\u0629 \u062c\u062f\u064a\u062f',
        title_en: 'New Ride Request',
        body_ar: '\u064a\u0648\u062c\u062f \u0637\u0644\u0628 \u0631\u062d\u0644\u0629 \u062c\u062f\u064a\u062f \u0641\u064a \u0645\u0646\u0637\u0642\u062a\u0643',
        body_en: 'New ride request in your area',
        type: 'RIDE_NEW',
        is_read: false,
      },
    ],
  });
  console.log('✓ Created 3 notifications');

  // ─── Summary ───────────────────────────────────────────────────────────────────────
  console.log(`
\u2554\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2557
\u2551           SEED COMPLETED \u2713                \u2551
\u2560\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2563
\u2551 Admin:   admin@doz.com / admin123         \u2551
\u2551 Rider 1: ahmed@example.com / rider123     \u2551
\u2551 Rider 2: sara@example.com / rider123      \u2551
\u2551 Rider 3: mohammad@example.com / rider123  \u2551
\u2551 Driver 1: khalid.driver@example.com       \u2551
\u2551 Driver 2: omar.driver@example.com         \u2551
\u2551 Driver 3: sami.driver@example.com         \u2551
\u2551 All driver passwords: driver123           \u2551
\u2560\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2563
\u2551 Vehicle types: Economy, Comfort,          \u2551
\u2551                Premium, Lux               \u2551
\u2551 Promo codes: WELCOME10, DOZ5OFF           \u2551
\u2551 Rides: 5 (2 completed, 1 in progress,    \u2551
\u2551         1 bidding, 1 cancelled)           \u2551
\u255a\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u255d
  `);
}

main()
  .then(() => prisma.$disconnect())
  .catch(async (err) => {
    console.error('Seed failed:', err);
    await prisma.$disconnect();
    process.exit(1);
  });
