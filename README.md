# DOZ Taxi 🚕

Professional ride-hailing platform with a bidding system similar to InDrive.

## Features

- **Bidding System**: Riders set their price, drivers place counter-bids
- **Real-time Tracking**: WebSocket-based live updates
- **Admin Dashboard**: Full management panel with analytics
- **Bilingual**: Arabic (RTL) + English support
- **Commission System**: 20% platform commission

## Architecture

```
doz-taxi/
├── backend/
│   ├── server.js          # Main Express server
│   ├── db.js              # JSON file-based database
│   └── package.json
├── frontend/
│   ├── index.html          # Landing page
│   ├── admin/index.html    # Admin dashboard
│   ├── rider/index.html    # Rider app
│   ├── driver/index.html   # Driver app
│   └── shared/
│       ├── api.js          # Shared API client & utilities
│       └── styles.css      # Shared design system
```

## Tech Stack

- **Backend**: Node.js, Express, WebSocket (ws)
- **Auth**: JWT (jsonwebtoken) + bcryptjs
- **Database**: JSON file-based (production: swap to PostgreSQL/MySQL)
- **Frontend**: Vanilla HTML/CSS/JS, Mobile-first responsive

## Quick Start

```bash
# Install dependencies
cd backend
npm install

# Start server
node server.js
```

Server runs on `http://localhost:8000`

## Demo Credentials

| Role    | Email            | Password  |
|---------|------------------|-----------|
| Admin   | admin@doz.com    | admin123  |
| Driver  | omar@test.com    | 123456    |
| Rider   | ahmed@test.com   | 123456    |

## API Endpoints

### Auth
- `POST /api/v1/auth/register` - Register
- `POST /api/v1/auth/login` - Login

### Rides
- `POST /api/v1/rides` - Create ride
- `GET /api/v1/rides/available` - Available rides for bidding
- `GET /api/v1/rides/:id` - Get ride details
- `GET /api/v1/rides/:id/bids` - Get bids for ride
- `POST /api/v1/rides/:id/bid` - Place bid
- `POST /api/v1/rides/:id/bids/:bidId/accept` - Accept bid
- `PUT /api/v1/rides/:id/status` - Update ride status
- `POST /api/v1/rides/:id/cancel` - Cancel ride
- `POST /api/v1/rides/:id/rate` - Rate ride
- `GET /api/v1/rides/my` - My rides

### Driver
- `POST /api/v1/driver/register` - Register as driver
- `GET /api/v1/driver/profile` - Driver profile
- `POST /api/v1/driver/location` - Update location
- `PUT /api/v1/driver/status` - Set online/offline
- `GET /api/v1/driver/earnings` - Get earnings

### Admin
- `GET /api/v1/admin/dashboard` - Dashboard stats
- `GET /api/v1/admin/users` - List users
- `GET /api/v1/admin/rides` - List rides
- `GET /api/v1/admin/drivers` - List drivers
- `PUT /api/v1/admin/users/:id/toggle` - Activate/deactivate user
- `PUT /api/v1/admin/drivers/:id/verify` - Verify driver

### WebSocket
- `ws://localhost:8000/ws?token=JWT_TOKEN`

Events: `new_ride`, `new_bid`, `bid_accepted`, `bid_rejected`, `ride_update`, `driver_location`

## Environment Variables

| Variable     | Default                           | Description        |
|-------------|-----------------------------------|--------------------||
| PORT        | 8000                              | Server port        |
| JWT_SECRET  | doz-taxi-secret-key-2026          | JWT signing key    |

## License

MIT © DOZ Platform
