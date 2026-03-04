# DOZ Taxi - Professional Ride-Hailing Platform

<div align="center">

# 🚕 DOZ

**تطبيق توصيل ذكي - حدد سعرك واختر سائقك**

*Smart ride-hailing app with bidding system*

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-3178C6?logo=typescript)
![License](https://img.shields.io/badge/License-MIT-green)

</div>

---

## 📱 Overview

DOZ is a professional, production-ready ride-hailing platform similar to InDrive with a **price bidding system**. Riders suggest their price, drivers place bids, and riders choose the best offer.

### Key Features
- 🏷️ **Price Bidding System** - Riders set their price, drivers counter-offer
- 🗺️ **Real-time GPS Tracking** - Live driver location on map
- 💬 **WebSocket Communication** - Instant updates for rides, bids, location
- 🌍 **Bilingual (AR + EN)** - Full Arabic RTL support + English
- 💰 **Wallet System** - In-app wallet with top-up and payments
- ⭐ **Rating System** - Mutual ratings with tags and comments
- 📊 **Admin Dashboard** - Full management panel with analytics
- 🔐 **OTP Authentication** - Phone-based secure login
- 💳 **Multiple Payment Methods** - Cash, wallet, card

---

## 🏗️ Architecture

```
doz-flutter/
├── backend/                    # Node.js + TypeScript + Prisma API
│   ├── prisma/schema.prisma    # Database schema (13 models)
│   ├── src/
│   │   ├── routes/             # REST API endpoints
│   │   ├── services/           # Business logic layer
│   │   ├── ws/                 # WebSocket handler
│   │   ├── middleware/         # Auth, validation, error handling
│   │   └── utils/              # Helpers, seed data
│   └── package.json
│
├── packages/
│   ├── doz_shared/             # Shared Flutter package
│   │   ├── lib/models/         # 10 data models with serialization
│   │   ├── lib/services/       # API client, WebSocket, Auth, Location
│   │   ├── lib/theme/          # DOZ brand theme (dark + light)
│   │   ├── lib/l10n/           # 238 strings in Arabic + English
│   │   ├── lib/widgets/        # 10 reusable branded widgets
│   │   └── lib/utils/          # Formatters, validators, extensions
│   │
│   ├── doz_rider/              # 🟢 Rider Mobile App (23 screens)
│   │   ├── lib/providers/      # Auth, Ride, Bids, Location, Wallet
│   │   ├── lib/screens/        # All rider screens
│   │   └── lib/navigation/     # GoRouter config
│   │
│   ├── doz_driver/             # 🔵 Driver Mobile App (24 screens)
│   │   ├── lib/providers/      # Auth, Driver, Ride, Earnings
│   │   ├── lib/screens/        # All driver screens
│   │   └── lib/navigation/     # GoRouter config
│   │
│   └── doz_admin/              # 🟡 Admin Dashboard (13 screens)
│       ├── lib/providers/      # 7 providers for admin features
│       ├── lib/screens/        # Dashboard, rides, users, revenue...
│       ├── lib/widgets/        # Sidebar, scaffold, data tables
│       └── lib/navigation/     # GoRouter with auth guards
│
├── melos.yaml                  # Monorepo management
└── README.md
```

---

## 📊 Project Stats

| Component | Files | Lines of Code |
|-----------|-------|---------------|
| **Shared Package** | 47 | ~6,900 |
| **Rider App** | 42 | ~8,600 |
| **Driver App** | 40 | ~8,700 |
| **Admin Dashboard** | 33 | ~8,900 |
| **Backend API** | 25 | ~4,400 |
| **Total** | **~190** | **~37,500** |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10+
- Node.js 18+
- npm or yarn

### 1. Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Generate Prisma client
npx prisma generate

# Create database & apply schema
npx prisma db push

# Seed demo data
npm run seed

# Start development server
npm run dev
```

The API runs on `http://localhost:8000`

### 2. Flutter Apps Setup

```bash
# Install Melos (monorepo tool)
dart pub global activate melos

# Bootstrap all packages
melos bootstrap

# Run Rider App
cd packages/doz_rider
flutter run

# Run Driver App
cd packages/doz_driver
flutter run

# Run Admin Dashboard (Web)
cd packages/doz_admin
flutter run -d chrome
```

### 3. Google Maps Setup

1. Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable: Maps SDK for Android, Maps SDK for iOS, Places API, Directions API
3. Add key to:
   - `packages/doz_rider/android/app/src/main/AndroidManifest.xml`
   - `packages/doz_rider/ios/Runner/AppDelegate.swift`
   - `packages/doz_driver/android/app/src/main/AndroidManifest.xml`
   - `packages/doz_driver/ios/Runner/AppDelegate.swift`

---

## 🔑 Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@doz.com | admin123 |
| Driver | omar@test.com | 123456 |
| Driver | sara@test.com | 123456 |
| Rider | ahmed@test.com | 123456 |
| Rider | layla@test.com | 123456 |

OTP in dev mode: `123456`

---

## 📱 Rider App Screens

| Screen | Description |
|--------|-------------|
| Splash | Animated logo + auth check |
| Onboarding | 3-page intro with illustrations |
| Login | Phone number + country code |
| OTP | 6-digit verification |
| Register | Name + email (first-time) |
| Home | Full map + "Where to?" drawer |
| Location Search | Place search with recents |
| Confirm Ride | Route + vehicle type picker |
| Set Price | Bidding with +/- controls |
| Finding Drivers | Search animation + timer |
| Bids | Incoming driver bids list |
| Driver Arriving | Live tracking to pickup |
| In-Ride | Live trip with SOS + share |
| Ride Complete | Fare breakdown |
| Rate Driver | Stars + tags + tip |
| Rides History | Active/Completed/Cancelled tabs |
| Ride Detail | Full trip details |
| Wallet | Balance + transactions |
| Top Up | Add money to wallet |
| Profile | User info + settings menu |
| Edit Profile | Update info + avatar |
| Settings | Language, notifications |
| Notifications | All notifications |

---

## 🚗 Driver App Screens

| Screen | Description |
|--------|-------------|
| Splash | Driver-branded splash |
| Login/OTP | Phone verification |
| Register | Personal + vehicle info |
| Home | Map + Online/Offline toggle |
| New Ride Popup | Incoming request (30s timer) |
| Place Bid | Set bid amount + earnings calc |
| Navigate to Pickup | Route to rider |
| At Pickup | Wait for rider + start |
| In-Trip | Navigation to dropoff |
| Complete Ride | Earnings breakdown |
| Rate Rider | Stars + tags |
| Rides History | Trip history |
| Earnings | Dashboard with charts |
| Wallet | Balance + withdraw |
| Profile | Info + vehicle + documents |
| Vehicle Info | Edit vehicle details |
| Documents | Upload license, ID |

---

## 🖥️ Admin Dashboard Screens

| Screen | Description |
|--------|-------------|
| Login | Admin email + password |
| Dashboard | Stats, charts, recent rides |
| Rides | Manage all rides + filters |
| Riders | User management |
| Drivers | Driver approval + management |
| Payments | Transaction history |
| Revenue | Analytics + reports |
| Vehicle Types | Configure vehicle categories |
| Promo Codes | Discount management |
| Support | Ticket management |
| Settings | System configuration |

---

## 🔌 API Endpoints

### Authentication
```
POST /api/v1/auth/register
POST /api/v1/auth/login
POST /api/v1/auth/send-otp
POST /api/v1/auth/verify-otp
POST /api/v1/auth/refresh-token
GET  /api/v1/auth/me
PUT  /api/v1/auth/me
```

### Rides
```
POST /api/v1/rides
GET  /api/v1/rides
GET  /api/v1/rides/:id
PUT  /api/v1/rides/:id/cancel
PUT  /api/v1/rides/:id/accept
PUT  /api/v1/rides/:id/arrive
PUT  /api/v1/rides/:id/start
PUT  /api/v1/rides/:id/complete
POST /api/v1/rides/:id/rate
```

### Bids
```
POST /api/v1/bids
GET  /api/v1/bids/ride/:rideId
PUT  /api/v1/bids/:id/accept
PUT  /api/v1/bids/:id/reject
```

### Drivers
```
PUT  /api/v1/drivers/status
PUT  /api/v1/drivers/location
GET  /api/v1/drivers/nearby
GET  /api/v1/drivers/earnings
GET  /api/v1/drivers/stats
```

### Payments & Wallet
```
GET  /api/v1/payments/wallet
POST /api/v1/payments/wallet/topup
GET  /api/v1/payments/wallet/transactions
POST /api/v1/payments/pay
```

### WebSocket Events
```
Connect: ws://localhost:8000/ws?token=JWT_TOKEN

Server → Client:
  ride:new, bid:received, bid:accepted,
  ride:driver-arriving, ride:started, ride:completed,
  driver:location, notification:new

Client → Server:
  driver:update-location, driver:toggle-status
```

---

## 🎨 Design System

### Colors
| Color | Hex | Usage |
|-------|-----|-------|
| Primary Green | `#7ED321` | CTAs, active states, branding |
| Dark Background | `#1A1A2E` | Main app background |
| Surface Dark | `#16213E` | Cards, sheets |
| Card Dark | `#1F2937` | Elevated surfaces |

### Typography
- **Arabic**: Tajawal
- **English**: Inter
- Material Design 3 type scale

---

## 🏗️ Building for Production

### Android APK
```bash
cd packages/doz_rider
flutter build apk --release

cd packages/doz_driver
flutter build apk --release
```

### iOS IPA
```bash
cd packages/doz_rider
flutter build ios --release

cd packages/doz_driver
flutter build ios --release
```

### Admin Dashboard (Web)
```bash
cd packages/doz_admin
flutter build web --release
```

### Backend (Production)
1. Switch Prisma datasource from SQLite to PostgreSQL in `prisma/schema.prisma`
2. Set up environment variables (see `.env.example`)
3. Deploy to your server (AWS, GCP, DigitalOcean, etc.)

---

## 📄 License

MIT License - Free to use for commercial and personal projects.

---

<div align="center">

**Built with ❤️ for DOZ**

</div>