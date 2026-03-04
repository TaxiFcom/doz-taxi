# DOZ Backend API

Production-grade Node.js backend for the DOZ taxi/ride-hailing app.

## Tech Stack

- **Runtime**: Node.js with TypeScript
- **Framework**: Express.js
- **Database**: SQLite (dev) / PostgreSQL (production) via Prisma ORM
- **Real-time**: WebSocket (ws) + in-memory pub/sub event bus
- **Auth**: JWT (access + refresh tokens), OTP via SMS
- **Uploads**: Multer for avatar images

---

## Quick Start

### 1. Install dependencies
```bash
npm install
```

### 2. Set up environment
```bash
cp .env.example .env
# Edit .env with your settings (defaults work for dev)
```

### 3. Generate Prisma client & create database
```bash
npx prisma generate
npx prisma db push
```

### 4. Seed demo data
```bash
npm run seed
```

### 5. Start development server
```bash
npm run dev
```

Server starts at: `http://localhost:3000`  
WebSocket at: `ws://localhost:3000/ws`  
Health check: `http://localhost:3000/health`

---

## Demo Credentials

| Role   | Email                       | Password   |
|--------|-----------------------------|------------|
| Admin  | admin@doz.com               | admin123   |
| Rider 1| ahmed@example.com           | rider123   |
| Rider 2| sara@example.com            | rider123   |
| Rider 3| mohammad@example.com        | rider123   |
| Driver 1| khalid.driver@example.com  | driver123  |
| Driver 2| omar.driver@example.com    | driver123  |
| Driver 3| sami.driver@example.com    | driver123  |

**In development, OTP for all phone numbers is: `123456`**

---

## API Documentation

### Base URL
```
http://localhost:3000/api/v1
```

All authenticated endpoints require:
```
Authorization: Bearer <access_token>
```

---

### Auth (`/api/v1/auth`)

| Method | Endpoint         | Auth | Description |
|--------|-----------------|------|-------------|
| POST   | /register        | No   | Register new user |
| POST   | /login           | No   | Login with email+password or phone+password |
| POST   | /send-otp        | No   | Send OTP to phone |
| POST   | /verify-otp      | No   | Verify OTP (creates account if not exists) |
| POST   | /refresh-token   | No   | Refresh access token |
| GET    | /me              | Yes  | Get current user profile |
| PUT    | /me              | Yes  | Update profile |
| POST   | /me/avatar       | Yes  | Upload avatar image |

**Register example:**
```json
POST /api/v1/auth/register
{
  "name": "Ahmed Ali",
  "phone": "+962791234567",
  "email": "ahmed@example.com",
  "password": "mypassword",
  "role": "RIDER",
  "lang": "ar"
}
```

**Login response:**
```json
{
  "success": true,
  "data": {
    "user": { "id": "...", "name": "Ahmed", "role": "RIDER" },
    "access_token": "eyJhbGciOiJIUzI1NiIsInR...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR..."
  }
}
```

---

### Rides (`/api/v1/rides`)

| Method | Endpoint         | Auth | Role   | Description |
|--------|-----------------|------|--------|-------------|
| POST   | /               | Yes  | RIDER  | Create ride request |
| GET    | /               | Yes  | Any    | List rides (filtered by role) |
| GET    | /:id            | Yes  | Any    | Get ride details |
| PUT    | /:id/cancel     | Yes  | Any    | Cancel ride |
| PUT    | /:id/arrive     | Yes  | DRIVER | Confirm driver arrived at pickup |
| PUT    | /:id/start      | Yes  | DRIVER | Start the ride |
| PUT    | /:id/complete   | Yes  | DRIVER | Complete the ride |
| POST   | /:id/rate       | Yes  | Any    | Rate the ride (1-5 stars) |

**Create ride example:**
```json
POST /api/v1/rides
{
  "pickup_lat": 31.9566,
  "pickup_lng": 35.9458,
  "pickup_address": "Shmeisani, Amman",
  "dropoff_lat": 31.9816,
  "dropoff_lng": 35.9120,
  "dropoff_address": "University of Jordan",
  "vehicle_type_id": "uuid-of-economy",
  "payment_method": "CASH"
}
```

**Ride statuses:**
```
PENDING → BIDDING → ACCEPTED → DRIVER_ARRIVING → IN_PROGRESS → COMPLETED
                                    ↓
                                CANCELLED
```

---

### Bids (`/api/v1/bids`)

| Method | Endpoint           | Auth | Role   | Description |
|--------|--------------------|------|--------|-------------|
| POST   | /                  | Yes  | DRIVER | Submit bid on a ride |
| GET    | /ride/:rideId      | Yes  | Any    | Get bids for a ride |
| PUT    | /:id/accept        | Yes  | RIDER  | Accept a bid |
| PUT    | /:id/reject        | Yes  | RIDER  | Reject a bid |

**Create bid example:**
```json
POST /api/v1/bids
{
  "ride_id": "uuid-of-ride",
  "amount": 4.50,
  "note": "سأصل خلال 3 دقائق",
  "eta_min": 3
}
```

---

### Drivers (`/api/v1/drivers`)

| Method | Endpoint        | Auth | Role   | Description |
|--------|----------------|------|--------|-------------|
| PUT    | /status         | Yes  | DRIVER | Toggle online/offline |
| PUT    | /location       | Yes  | DRIVER | Update GPS coordinates |
| GET    | /nearby         | Yes  | Any    | Find nearby available drivers |
| GET    | /earnings       | Yes  | DRIVER | Get earnings summary |
| GET    | /stats          | Yes  | DRIVER | Get driver statistics |

**Find nearby drivers:**
```
GET /api/v1/drivers/nearby?lat=31.9566&lng=35.9458&radius=5
```

---

### Payments (`/api/v1/payments`)

| Method | Endpoint                  | Auth | Description |
|--------|--------------------------|------|-------------|
| GET    | /wallet                   | Yes  | Get wallet balance |
| POST   | /wallet/topup             | Yes  | Top up wallet |
| GET    | /wallet/transactions      | Yes  | Transaction history |
| POST   | /pay                      | Yes  | Process ride payment |

**Top-up example:**
```json
POST /api/v1/payments/wallet/topup
{
  "amount": 20.00,
  "method": "CARD"
}
```

---

### Notifications (`/api/v1/notifications`)

| Method | Endpoint     | Auth | Description |
|--------|-------------|------|-------------|
| GET    | /            | Yes  | List notifications (paginated) |
| PUT    | /:id/read    | Yes  | Mark single as read |
| PUT    | /read-all    | Yes  | Mark all as read |

---

### Admin (`/api/v1/admin`) — Requires ADMIN role

| Method | Endpoint                    | Description |
|--------|-----------------------------|-------------|
| GET    | /dashboard                  | Dashboard stats & overview |
| GET    | /rides                      | All rides with filters |
| GET    | /users                      | All users with filters |
| PUT    | /users/:id                  | Update user (ban/activate) |
| GET    | /drivers                    | All drivers |
| PUT    | /drivers/:id/approve        | Approve a driver |
| GET    | /payments                   | Payment reports |
| GET    | /earnings                   | Revenue reports |
| POST   | /promo-codes                | Create promo code |
| GET    | /promo-codes                | List promo codes |
| GET    | /vehicle-types              | List vehicle types |
| POST   | /vehicle-types              | Create vehicle type |

---

### Public Endpoints

| Method | Endpoint                    | Description |
|--------|-----------------------------|-------------|
| GET    | /api/v1/vehicle-types       | List active vehicle types |
| POST   | /api/v1/promo-codes/validate| Validate a promo code |
| GET    | /health                     | Health check |

---

## WebSocket

Connect to `ws://localhost:3000/ws?token=<access_token>`

### Server → Client Events

| Event                | Description |
|---------------------|-------------|
| `ride:new`          | New ride request (sent to nearby drivers) |
| `bid:received`      | New bid on rider's ride |
| `bid:accepted`      | Bid accepted notification |
| `ride:driver-arriving` | Driver confirmed arrival at pickup |
| `ride:started`      | Ride has started |
| `ride:completed`    | Ride completed |
| `driver:location`   | Real-time driver GPS update |
| `notification:new`  | Push notification |

### Client → Server Events

| Event                   | Data | Description |
|------------------------|------|-------------|
| `driver:update-location`| `{lat, lng, heading}` | Driver sends GPS |
| `driver:toggle-status`  | `{is_online: bool}` | Go online/offline |
| `rider:subscribe-ride`  | `{ride_id}` | Subscribe to ride updates |
| `ping`                  | — | Keep-alive ping |

**Example (JavaScript):**
```js
const ws = new WebSocket('ws://localhost:3000/ws?token=eyJ...');

ws.onopen = () => {
  // Subscribe to a ride
  ws.send(JSON.stringify({ 
    type: 'rider:subscribe-ride', 
    data: { ride_id: 'uuid' } 
  }));
};

ws.onmessage = (e) => {
  const event = JSON.parse(e.data);
  console.log(event.type, event);
};
```

---

## Switching to PostgreSQL

Change `prisma/schema.prisma`:
```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

Update `.env`:
```
DATABASE_URL="postgresql://user:password@localhost:5432/doz_db"
```

Then run:
```bash
npx prisma migrate dev --name init
```

---

## Project Structure

```
backend/
├── prisma/
│   └── schema.prisma          # Database schema (SQLite/PostgreSQL)
├── src/
│   ├── index.ts               # App entry point, HTTP + WS server
│   ├── config.ts              # Environment configuration
│   ├── middleware/
│   │   ├── auth.ts            # JWT authentication middleware
│   │   ├── validate.ts        # Request validation middleware
│   │   └── errorHandler.ts    # Global error handler
│   ├── routes/
│   │   ├── auth.ts            # Auth endpoints
│   │   ├── rides.ts           # Ride management
│   │   ├── bids.ts            # Bidding system
│   │   ├── drivers.ts         # Driver endpoints
│   │   ├── payments.ts        # Wallet & payments
│   │   ├── notifications.ts   # Notifications
│   │   └── admin.ts           # Admin dashboard
│   ├── services/
│   │   ├── rideService.ts     # Ride business logic
│   │   ├── bidService.ts      # Bidding logic
│   │   ├── paymentService.ts  # Payment processing
│   │   ├── notificationService.ts # Notification dispatch
│   │   ├── locationService.ts # Haversine / geo utils
│   │   └── eventBus.ts        # In-memory pub/sub
│   ├── ws/
│   │   └── handler.ts         # WebSocket server & event routing
│   └── utils/
│       ├── helpers.ts         # JWT, bcrypt, OTP, pagination utils
│       └── seed.ts            # Database seeder
├── uploads/                   # Uploaded files (gitignored in prod)
├── .env.example               # Environment template
├── package.json
├── tsconfig.json
└── README.md
```

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3000` | Server port |
| `DATABASE_URL` | `file:./dev.db` | SQLite/PostgreSQL connection string |
| `JWT_SECRET` | — | JWT signing secret (min 32 chars) |
| `JWT_REFRESH_SECRET` | — | Refresh token secret |
| `JWT_EXPIRES_IN` | `15m` | Access token TTL |
| `JWT_REFRESH_EXPIRES_IN` | `7d` | Refresh token TTL |
| `OTP_EXPIRY_MINUTES` | `5` | OTP validity window |
| `DEFAULT_COMMISSION_RATE` | `0.15` | Platform commission (15%) |
| `UPLOAD_DIR` | `./uploads` | File upload directory |
| `FRONTEND_URL` | `http://localhost:3001` | CORS allowed origin |

---

## Production Checklist

- [ ] Switch `DATABASE_URL` to PostgreSQL
- [ ] Set strong `JWT_SECRET` and `JWT_REFRESH_SECRET` (32+ chars)
- [ ] Integrate SMS provider (Twilio/Unifonic) in `routes/auth.ts`
- [ ] Add rate limiting (e.g., `express-rate-limit`)
- [ ] Configure HTTPS / TLS termination
- [ ] Set `FRONTEND_URL` to actual domain
- [ ] Replace in-memory `eventBus` with Redis pub/sub for multi-instance support
- [ ] Add request logging to external service (DataDog, Sentry)
- [ ] Set `NODE_ENV=production`
- [ ] Run `npm run build && npm start` (not `npm run dev`)
