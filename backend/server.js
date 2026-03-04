/**
 * DOZ Taxi - Main Server
 * Professional ride-hailing backend with bidding system
 */
const express = require('express');
const cors = require('cors');
const http = require('http');
const { WebSocketServer } = require('ws');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const db = require('./db');
const path = require('path');

const app = express();
const server = http.createServer(app);

// Config
const PORT = process.env.PORT || 8000;
const JWT_SECRET = process.env.JWT_SECRET || 'doz-taxi-secret-key-2026';
const JWT_EXPIRES = '24h';
const COMMISSION_RATE = 0.20; // 20% platform commission

// Middleware
app.use(cors());
app.use(express.json());

// ================== HELPERS ==================
function respond(res, status, success, data, error) {
  return res.status(status).json({ success, ...(data !== undefined && { data }), ...(error && { error }) });
}

function genToken(user) {
  return jwt.sign({ user_id: user.id, role: user.role, email: user.email }, JWT_SECRET, { expiresIn: JWT_EXPIRES });
}

function auth(req, res, next) {
  const h = req.headers.authorization;
  if (!h || !h.startsWith('Bearer ')) return respond(res, 401, false, undefined, 'Authorization required');
  try {
    const decoded = jwt.verify(h.split(' ')[1], JWT_SECRET);
    req.user = decoded;
    next();
  } catch { return respond(res, 401, false, undefined, 'Invalid or expired token'); }
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) return respond(res, 403, false, undefined, 'Insufficient permissions');
    next();
  };
}

function getPage(req) {
  let page = parseInt(req.query.page) || 1;
  let per_page = parseInt(req.query.per_page) || 20;
  if (page < 1) page = 1;
  if (per_page < 1 || per_page > 100) per_page = 20;
  return { page, per_page };
}

function sanitizeUser(u) {
  const { password, ...safe } = u;
  return safe;
}

// ================== WEBSOCKET ==================
const wss = new WebSocketServer({ server, path: '/ws' });
const wsClients = new Map(); // user_id -> ws

wss.on('connection', (ws, req) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  const token = url.searchParams.get('token');
  if (!token) { ws.close(1008, 'Token required'); return; }
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    ws.userId = decoded.user_id;
    ws.userRole = decoded.role;
    wsClients.set(decoded.user_id, ws);
    console.log(`WS connected: ${decoded.user_id} (${decoded.role})`);
    ws.on('close', () => { wsClients.delete(decoded.user_id); });
    ws.on('error', () => { wsClients.delete(decoded.user_id); });
  } catch { ws.close(1008, 'Invalid token'); }
});

function sendToUser(userId, type, payload) {
  const ws = wsClients.get(userId);
  if (ws && ws.readyState === 1) ws.send(JSON.stringify({ type, payload }));
}

function sendToRole(role, type, payload) {
  const msg = JSON.stringify({ type, payload });
  wsClients.forEach((ws) => {
    if (ws.userRole === role && ws.readyState === 1) ws.send(msg);
  });
}

function broadcast(type, payload) {
  const msg = JSON.stringify({ type, payload });
  wsClients.forEach((ws) => { if (ws.readyState === 1) ws.send(msg); });
}

// ================== AUTH ROUTES ==================
const api = express.Router();

api.post('/auth/register', async (req, res) => {
  const { name, email, phone, password, role = 'rider', lang = 'ar' } = req.body;
  if (!name || !email || !phone || !password) return respond(res, 400, false, undefined, 'All fields are required');
  if (db.findOne('users', u => u.email === email)) return respond(res, 400, false, undefined, 'Email already registered');

  const user = {
    id: uuidv4(), name, email, phone,
    password: await bcrypt.hash(password, 10),
    role, avatar: '', rating: 5.0, ride_count: 0,
    is_active: true, lang, created_at: new Date().toISOString(), updated_at: new Date().toISOString()
  };
  db.insert('users', user);
  respond(res, 201, true, { user: sanitizeUser(user), token: genToken(user) });
});

api.post('/auth/login', async (req, res) => {
  const { email, password } = req.body;
  const user = db.findOne('users', u => u.email === email);
  if (!user) return respond(res, 401, false, undefined, 'Invalid credentials');
  if (!user.is_active) return respond(res, 401, false, undefined, 'Account is deactivated');
  const valid = await bcrypt.compare(password, user.password);
  if (!valid) return respond(res, 401, false, undefined, 'Invalid credentials');
  respond(res, 200, true, { user: sanitizeUser(user), token: genToken(user) });
});

// ================== USER ROUTES ==================
api.get('/profile', auth, (req, res) => {
  const user = db.findOne('users', u => u.id === req.user.user_id);
  if (!user) return respond(res, 404, false, undefined, 'User not found');
  respond(res, 200, true, sanitizeUser(user));
});

api.put('/profile', auth, (req, res) => {
  const { name, phone, lang } = req.body;
  db.update('users', u => u.id === req.user.user_id, { name, phone, lang, updated_at: new Date().toISOString() });
  respond(res, 200, true, undefined, undefined);
});

// ================== RIDE ROUTES ==================
api.post('/rides', auth, (req, res) => {
  const { pickup_lat, pickup_lng, pickup_address, dropoff_lat, dropoff_lng, dropoff_address, offered_price, vehicle_type = 'sedan' } = req.body;
  if (!pickup_address || !dropoff_address || !offered_price || offered_price <= 0) {
    return respond(res, 400, false, undefined, 'Pickup, dropoff and price are required');
  }
  const ride = {
    id: uuidv4(), rider_id: req.user.user_id, driver_id: null,
    pickup_lat, pickup_lng, pickup_address, dropoff_lat, dropoff_lng, dropoff_address,
    offered_price, final_price: 0, distance: 0, duration: 0,
    status: 'bidding', vehicle_type, rating: 0, review: '',
    created_at: new Date().toISOString(), updated_at: new Date().toISOString(), completed_at: null
  };
  db.insert('rides', ride);
  const rider = db.findOne('users', u => u.id === req.user.user_id);
  ride.rider = rider ? sanitizeUser(rider) : null;
  sendToRole('driver', 'new_ride', ride);
  respond(res, 201, true, ride);
});

api.get('/rides/available', auth, (req, res) => {
  const vType = req.query.vehicle_type;
  let rides = db.find('rides', r => r.status === 'bidding');
  if (vType) rides = rides.filter(r => r.vehicle_type === vType);
  rides.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  rides = rides.slice(0, 50).map(r => {
    const rider = db.findOne('users', u => u.id === r.rider_id);
    return { ...r, rider: rider ? { id: rider.id, name: rider.name, rating: rider.rating } : null };
  });
  respond(res, 200, true, rides);
});

api.get('/rides/my', auth, (req, res) => {
  const { page, per_page } = getPage(req);
  const field = req.user.role === 'driver' ? 'driver_id' : 'rider_id';
  const result = db.paginate('rides', r => r[field] === req.user.user_id, page, per_page);
  respond(res, 200, true, result);
});

api.get('/rides/:id', auth, (req, res) => {
  const ride = db.findOne('rides', r => r.id === req.params.id);
  if (!ride) return respond(res, 404, false, undefined, 'Ride not found');
  if (ride.rider_id) {
    const rider = db.findOne('users', u => u.id === ride.rider_id);
    if (rider) ride.rider = sanitizeUser(rider);
  }
  if (ride.driver_id) {
    const driver = db.findOne('drivers', d => d.user_id === ride.driver_id);
    const driverUser = db.findOne('users', u => u.id === ride.driver_id);
    if (driver && driverUser) ride.driver = { ...driver, user: sanitizeUser(driverUser) };
  }
  respond(res, 200, true, ride);
});

api.get('/rides/:id/bids', auth, (req, res) => {
  const bids = db.find('bids', b => b.ride_id === req.params.id);
  bids.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  const enriched = bids.map(b => {
    const driver = db.findOne('drivers', d => d.user_id === b.driver_id);
    const user = db.findOne('users', u => u.id === b.driver_id);
    return {
      ...b,
      driver: driver ? {
        ...driver,
        user: user ? { id: user.id, name: user.name, rating: user.rating, ride_count: user.ride_count } : null
      } : null
    };
  });
  respond(res, 200, true, enriched);
});

api.post('/rides/:id/bid', auth, (req, res) => {
  const ride = db.findOne('rides', r => r.id === req.params.id);
  if (!ride) return respond(res, 404, false, undefined, 'Ride not found');
  if (ride.status !== 'bidding') return respond(res, 400, false, undefined, 'Ride is not accepting bids');

  const existing = db.findOne('bids', b => b.ride_id === req.params.id && b.driver_id === req.user.user_id && b.status === 'pending');
  if (existing) return respond(res, 400, false, undefined, 'You already have a pending bid');

  const { amount } = req.body;
  if (!amount || amount <= 0) return respond(res, 400, false, undefined, 'Valid amount required');

  const bid = {
    id: uuidv4(), ride_id: req.params.id, driver_id: req.user.user_id,
    amount, status: 'pending', created_at: new Date().toISOString()
  };
  db.insert('bids', bid);

  const driver = db.findOne('drivers', d => d.user_id === req.user.user_id);
  const driverUser = db.findOne('users', u => u.id === req.user.user_id);
  sendToUser(ride.rider_id, 'new_bid', {
    bid, driver: driver ? { ...driver, user: driverUser ? sanitizeUser(driverUser) : null } : null
  });

  respond(res, 201, true, bid);
});

api.post('/rides/:id/bids/:bidId/accept', auth, (req, res) => {
  const bid = db.findOne('bids', b => b.id === req.params.bidId);
  if (!bid) return respond(res, 404, false, undefined, 'Bid not found');
  if (bid.status !== 'pending') return respond(res, 400, false, undefined, 'Bid is no longer pending');

  const ride = db.findOne('rides', r => r.id === bid.ride_id);
  if (!ride || ride.rider_id !== req.user.user_id) return respond(res, 403, false, undefined, 'Unauthorized');

  // Accept this bid, reject others
  db.update('bids', b => b.id === bid.id, { status: 'accepted' });
  db.find('bids', b => b.ride_id === bid.ride_id && b.id !== bid.id && b.status === 'pending')
    .forEach(b => db.update('bids', bb => bb.id === b.id, { status: 'rejected' }));
  db.update('rides', r => r.id === bid.ride_id, {
    driver_id: bid.driver_id, final_price: bid.amount, status: 'accepted', updated_at: new Date().toISOString()
  });
  db.update('drivers', d => d.user_id === bid.driver_id, { status: 'busy' });

  const updatedRide = db.findOne('rides', r => r.id === bid.ride_id);
  sendToUser(bid.driver_id, 'bid_accepted', updatedRide);

  // Notify rejected drivers
  db.find('bids', b => b.ride_id === bid.ride_id && b.status === 'rejected')
    .forEach(b => sendToUser(b.driver_id, 'bid_rejected', { ride_id: bid.ride_id }));

  respond(res, 200, true, updatedRide);
});

api.put('/rides/:id/status', auth, (req, res) => {
  const { status } = req.body;
  const ride = db.findOne('rides', r => r.id === req.params.id);
  if (!ride) return respond(res, 404, false, undefined, 'Ride not found');

  const updates = { status, updated_at: new Date().toISOString() };
  if (status === 'completed') {
    updates.completed_at = new Date().toISOString();
    if (ride.driver_id) {
      const earnings = ride.final_price * (1 - COMMISSION_RATE);
      const driver = db.findOne('drivers', d => d.user_id === ride.driver_id);
      if (driver) db.update('drivers', d => d.user_id === ride.driver_id, {
        status: 'available', earnings: (driver.earnings || 0) + earnings
      });
      db.update('users', u => u.id === ride.driver_id, {
        ride_count: (db.findOne('users', u => u.id === ride.driver_id)?.ride_count || 0) + 1
      });
    }
    db.update('users', u => u.id === ride.rider_id, {
      ride_count: (db.findOne('users', u => u.id === ride.rider_id)?.ride_count || 0) + 1
    });
  }
  if (status === 'cancelled' && ride.driver_id) {
    db.update('drivers', d => d.user_id === ride.driver_id, { status: 'available' });
  }

  db.update('rides', r => r.id === req.params.id, updates);
  const updated = db.findOne('rides', r => r.id === req.params.id);
  sendToUser(ride.rider_id, 'ride_update', updated);
  if (ride.driver_id) sendToUser(ride.driver_id, 'ride_update', updated);
  respond(res, 200, true, updated);
});

api.post('/rides/:id/cancel', auth, (req, res) => {
  const ride = db.findOne('rides', r => r.id === req.params.id);
  if (!ride) return respond(res, 404, false, undefined, 'Ride not found');
  if (ride.rider_id !== req.user.user_id && ride.driver_id !== req.user.user_id) {
    return respond(res, 403, false, undefined, 'Unauthorized');
  }
  if (['completed', 'cancelled'].includes(ride.status)) {
    return respond(res, 400, false, undefined, 'Ride cannot be cancelled');
  }
  db.update('rides', r => r.id === req.params.id, { status: 'cancelled', updated_at: new Date().toISOString() });
  if (ride.driver_id) db.update('drivers', d => d.user_id === ride.driver_id, { status: 'available' });
  sendToUser(ride.rider_id, 'ride_update', { ...ride, status: 'cancelled' });
  if (ride.driver_id) sendToUser(ride.driver_id, 'ride_update', { ...ride, status: 'cancelled' });
  respond(res, 200, true, undefined);
});

api.post('/rides/:id/rate', auth, (req, res) => {
  const { rating, review = '' } = req.body;
  const ride = db.findOne('rides', r => r.id === req.params.id);
  if (!ride || ride.rider_id !== req.user.user_id) return respond(res, 403, false, undefined, 'Unauthorized');
  if (ride.status !== 'completed') return respond(res, 400, false, undefined, 'Can only rate completed rides');

  db.update('rides', r => r.id === req.params.id, { rating, review });
  if (ride.driver_id) {
    const driverRides = db.find('rides', r => r.driver_id === ride.driver_id && r.rating > 0);
    const avg = driverRides.reduce((sum, r) => sum + r.rating, rating) / (driverRides.length + 1);
    db.update('users', u => u.id === ride.driver_id, { rating: Math.round(avg * 10) / 10 });
  }
  respond(res, 200, true, undefined);
});

// ================== DRIVER ROUTES ==================
api.post('/driver/register', auth, (req, res) => {
  if (db.findOne('drivers', d => d.user_id === req.user.user_id)) {
    return respond(res, 400, false, undefined, 'Driver profile already exists');
  }
  const { vehicle_type = 'sedan', vehicle_model, vehicle_color, plate_number, license_no } = req.body;
  if (!vehicle_model || !vehicle_color || !plate_number || !license_no) {
    return respond(res, 400, false, undefined, 'All vehicle details required');
  }
  const driver = {
    user_id: req.user.user_id, vehicle_type, vehicle_model, vehicle_color,
    plate_number, license_no, status: 'offline', lat: 0, lng: 0,
    earnings: 0, is_verified: false
  };
  db.insert('drivers', driver);
  // Update user role
  db.update('users', u => u.id === req.user.user_id, { role: 'driver' });
  respond(res, 201, true, driver);
});

api.get('/driver/profile', auth, (req, res) => {
  const driver = db.findOne('drivers', d => d.user_id === req.user.user_id);
  if (!driver) return respond(res, 404, false, undefined, 'Driver profile not found');
  const user = db.findOne('users', u => u.id === req.user.user_id);
  respond(res, 200, true, { ...driver, user: user ? sanitizeUser(user) : null });
});

api.post('/driver/location', auth, (req, res) => {
  const { lat, lng, heading = 0, speed = 0 } = req.body;
  db.update('drivers', d => d.user_id === req.user.user_id, { lat, lng });
  broadcast('driver_location', { user_id: req.user.user_id, lat, lng, heading, speed });
  respond(res, 200, true, undefined);
});

api.put('/driver/status', auth, (req, res) => {
  const { status } = req.body;
  if (!['offline', 'available', 'busy'].includes(status)) return respond(res, 400, false, undefined, 'Invalid status');
  db.update('drivers', d => d.user_id === req.user.user_id, { status });
  respond(res, 200, true, undefined);
});

api.get('/driver/earnings', auth, (req, res) => {
  const period = req.query.period || 'today';
  const now = new Date();
  let filter;
  if (period === 'today') {
    const today = now.toISOString().split('T')[0];
    filter = r => r.driver_id === req.user.user_id && r.status === 'completed' && r.completed_at && r.completed_at.startsWith(today);
  } else if (period === 'week') {
    const weekAgo = new Date(now - 7 * 86400000).toISOString();
    filter = r => r.driver_id === req.user.user_id && r.status === 'completed' && r.completed_at && r.completed_at >= weekAgo;
  } else {
    const monthAgo = new Date(now - 30 * 86400000).toISOString();
    filter = r => r.driver_id === req.user.user_id && r.status === 'completed' && r.completed_at && r.completed_at >= monthAgo;
  }
  const rides = db.find('rides', filter);
  const earnings = rides.reduce((sum, r) => sum + r.final_price * (1 - COMMISSION_RATE), 0);
  respond(res, 200, true, { earnings: Math.round(earnings * 100) / 100, rides_count: rides.length, period });
});

api.get('/drivers/nearby', auth, (req, res) => {
  const lat = parseFloat(req.query.lat) || 0;
  const lng = parseFloat(req.query.lng) || 0;
  const radius = parseFloat(req.query.radius) || 5;
  const degRadius = radius / 111.0;
  const drivers = db.find('drivers', d => d.status === 'available' && Math.abs(d.lat - lat) < degRadius && Math.abs(d.lng - lng) < degRadius);
  const enriched = drivers.map(d => {
    const user = db.findOne('users', u => u.id === d.user_id);
    return { ...d, user: user ? { id: user.id, name: user.name, rating: user.rating } : null };
  });
  respond(res, 200, true, enriched);
});

// ================== ADMIN ROUTES ==================
const admin = express.Router();
admin.use(auth, requireRole('admin', 'staff'));

admin.get('/dashboard', (req, res) => {
  const totalRiders = db.count('users', u => u.role === 'rider');
  const totalDrivers = db.count('users', u => u.role === 'driver');
  const totalRides = db.count('rides');
  const activeRides = db.count('rides', r => ['pending', 'bidding', 'accepted', 'driver_en_route', 'in_progress'].includes(r.status));
  const completedRides = db.find('rides', r => r.status === 'completed');
  const totalRevenue = completedRides.reduce((s, r) => s + (r.final_price || 0), 0);
  const today = new Date().toISOString().split('T')[0];
  const todayRides = db.find('rides', r => r.created_at.startsWith(today));
  const todayCompleted = todayRides.filter(r => r.status === 'completed');
  const todayRevenue = todayCompleted.reduce((s, r) => s + (r.final_price || 0), 0);
  const ratedRides = db.find('rides', r => r.rating > 0);
  const avgRating = ratedRides.length ? ratedRides.reduce((s, r) => s + r.rating, 0) / ratedRides.length : 0;
  const onlineDrivers = db.count('drivers', d => d.status === 'available');
  const finishedRides = db.count('rides', r => ['completed', 'cancelled'].includes(r.status));
  const completionRate = finishedRides ? (completedRides.length / finishedRides) * 100 : 0;
  const platformRevenue = completedRides.reduce((s, r) => s + (r.final_price || 0) * COMMISSION_RATE, 0);

  respond(res, 200, true, {
    total_riders: totalRiders, total_drivers: totalDrivers, total_rides: totalRides,
    active_rides: activeRides, total_revenue: Math.round(totalRevenue * 100) / 100,
    today_rides: todayRides.length, today_revenue: Math.round(todayRevenue * 100) / 100,
    avg_rating: Math.round(avgRating * 10) / 10, online_drivers: onlineDrivers,
    completion_rate: Math.round(completionRate * 10) / 10,
    platform_revenue: Math.round(platformRevenue * 100) / 100
  });
});

admin.get('/users', (req, res) => {
  const { page, per_page } = getPage(req);
  const role = req.query.role;
  const predicate = role ? u => u.role === role : undefined;
  const result = db.paginate('users', predicate, page, per_page);
  result.data = result.data.map(sanitizeUser);
  respond(res, 200, true, result);
});

admin.put('/users/:id/toggle', (req, res) => {
  const { active } = req.body;
  db.update('users', u => u.id === req.params.id, { is_active: active, updated_at: new Date().toISOString() });
  respond(res, 200, true, undefined);
});

admin.get('/rides', (req, res) => {
  const { page, per_page } = getPage(req);
  const status = req.query.status;
  const predicate = status ? r => r.status === status : undefined;
  const result = db.paginate('rides', predicate, page, per_page);
  result.data = result.data.map(r => {
    const rider = db.findOne('users', u => u.id === r.rider_id);
    const driver = r.driver_id ? db.findOne('users', u => u.id === r.driver_id) : null;
    return { ...r, rider_name: rider?.name, driver_name: driver?.name };
  });
  respond(res, 200, true, result);
});

admin.get('/drivers', (req, res) => {
  const { page, per_page } = getPage(req);
  const status = req.query.status;
  const predicate = status ? d => d.status === status : undefined;
  const result = db.paginate('drivers', predicate, page, per_page, 'user_id');
  result.data = result.data.map(d => {
    const user = db.findOne('users', u => u.id === d.user_id);
    return { ...d, user: user ? sanitizeUser(user) : null };
  });
  respond(res, 200, true, result);
});

admin.put('/drivers/:id/verify', (req, res) => {
  const { verified } = req.body;
  db.update('drivers', d => d.user_id === req.params.id, { is_verified: verified });
  respond(res, 200, true, undefined);
});

app.use('/api/v1', api);
app.use('/api/v1/admin', admin);

// Serve frontend
const frontendDir = path.join(__dirname, '..', 'frontend');
app.use('/shared', express.static(path.join(frontendDir, 'shared')));
app.use('/admin', express.static(path.join(frontendDir, 'admin')));
app.use('/rider', express.static(path.join(frontendDir, 'rider')));
app.use('/driver', express.static(path.join(frontendDir, 'driver')));
app.get('/', (req, res) => res.sendFile(path.join(frontendDir, 'index.html')));

// Seed admin
if (!db.findOne('users', u => u.role === 'admin')) {
  bcrypt.hash('admin123', 10).then(hash => {
    db.insert('users', {
      id: 'admin-001', name: 'مدير النظام', email: 'admin@doz.com', phone: '+962000000000',
      password: hash, role: 'admin', avatar: '', rating: 5.0, ride_count: 0,
      is_active: true, lang: 'ar', created_at: new Date().toISOString(), updated_at: new Date().toISOString()
    });
    console.log('Default admin: admin@doz.com / admin123');
  });
}

// Seed demo data
function seedDemo() {
  if (db.count('users') > 1) return;
  bcrypt.hash('123456', 10).then(hash => {
    // Demo riders
    const riders = [
      { id: 'rider-001', name: 'أحمد محمد', email: 'ahmed@test.com', phone: '+962791234567' },
      { id: 'rider-002', name: 'سارة علي', email: 'sara@test.com', phone: '+962791234568' },
      { id: 'rider-003', name: 'محمد خالد', email: 'moh@test.com', phone: '+962791234569' },
    ];
    riders.forEach(r => db.insert('users', {
      ...r, password: hash, role: 'rider', avatar: '', rating: 4.5 + Math.random() * 0.5,
      ride_count: Math.floor(Math.random() * 20), is_active: true, lang: 'ar',
      created_at: new Date().toISOString(), updated_at: new Date().toISOString()
    }));

    // Demo drivers
    const driversList = [
      { id: 'driver-001', name: 'عمر يوسف', email: 'omar@test.com', phone: '+962791234570', model: 'Toyota Camry 2024', color: 'أبيض', plate: 'ع م 1234' },
      { id: 'driver-002', name: 'خالد أحمد', email: 'khalid@test.com', phone: '+962791234571', model: 'Hyundai Sonata 2023', color: 'أسود', plate: 'خ ا 5678' },
      { id: 'driver-003', name: 'فيصل عمر', email: 'faisal@test.com', phone: '+962791234572', model: 'Kia Optima 2023', color: 'رمادي', plate: 'ف ي 9012' },
    ];
    driversList.forEach(d => {
      db.insert('users', {
        id: d.id, name: d.name, email: d.email, phone: d.phone,
        password: hash, role: 'driver', avatar: '', rating: 4.3 + Math.random() * 0.7,
        ride_count: Math.floor(Math.random() * 50) + 10, is_active: true, lang: 'ar',
        created_at: new Date().toISOString(), updated_at: new Date().toISOString()
      });
      db.insert('drivers', {
        user_id: d.id, vehicle_type: 'sedan', vehicle_model: d.model, vehicle_color: d.color,
        plate_number: d.plate, license_no: 'LIC-' + d.id, status: 'available',
        lat: 31.95 + (Math.random() - 0.5) * 0.1, lng: 35.93 + (Math.random() - 0.5) * 0.1,
        earnings: Math.floor(Math.random() * 1000) + 200, is_verified: true
      });
    });
  });
}
seedDemo();

server.listen(PORT, () => {
  console.log(`DOZ Taxi server running on port ${PORT}`);
  console.log(`Frontend: http://localhost:${PORT}`);
  console.log(`Admin: http://localhost:${PORT}/admin`);
  console.log(`API: http://localhost:${PORT}/api/v1`);
});
