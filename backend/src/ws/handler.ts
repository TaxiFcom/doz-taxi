import { WebSocketServer, WebSocket } from 'ws';
import { IncomingMessage } from 'http';
import { Server } from 'http';
import { URL } from 'url';
import { verifyWsToken } from '../middleware/auth';
import { eventBus, CHANNELS } from '../services/eventBus';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

interface AuthenticatedSocket extends WebSocket {
  userId?: string;
  role?: string;
  driverId?: string;
  isAlive?: boolean;
}

// Track connected clients
const connectedClients = new Map<string, AuthenticatedSocket>();

function send(ws: AuthenticatedSocket, data: object): void {
  if (ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify(data));
  }
}

function broadcast(userIds: string[], data: object): void {
  for (const userId of userIds) {
    const client = connectedClients.get(userId);
    if (client) send(client, data);
  }
}

export function setupWebSocket(server: Server): WebSocketServer {
  const wss = new WebSocketServer({
    server,
    path: '/ws',
    verifyClient: ({ req }: { req: IncomingMessage }, done: (res: boolean, code?: number, msg?: string) => void) => {
      // Extract token from query string or Authorization header
      const urlStr = `http://localhost${req.url}`;
      const url = new URL(urlStr);
      const token = url.searchParams.get('token') ||
        (req.headers.authorization?.startsWith('Bearer ') ? req.headers.authorization.split(' ')[1] : null);

      if (!token) {
        done(false, 401, 'Token required');
        return;
      }

      const payload = verifyWsToken(token);
      if (!payload) {
        done(false, 401, 'Invalid token');
        return;
      }

      // Attach payload to request for use in connection handler
      (req as any).__user = payload;
      done(true);
    },
  });

  // ─── Heartbeat / Ping-Pong ─────────────────────────────────────────────────────
  const heartbeatInterval = setInterval(() => {
    wss.clients.forEach((wsRaw) => {
      const ws = wsRaw as AuthenticatedSocket;
      if (ws.isAlive === false) {
        ws.terminate();
        return;
      }
      ws.isAlive = false;
      ws.ping();
    });
  }, 30000);

  wss.on('close', () => clearInterval(heartbeatInterval));

  // ─── Connection Handler ───────────────────────────────────────────────────
  wss.on('connection', async (wsRaw: WebSocket, req: IncomingMessage) => {
    const ws = wsRaw as AuthenticatedSocket;
    const payload = (req as any).__user as { userId: string; role: string };

    ws.userId = payload.userId;
    ws.role = payload.role;
    ws.isAlive = true;

    // Handle pong
    ws.on('pong', () => { ws.isAlive = true; });

    // If driver, load driver profile
    if (payload.role === 'DRIVER') {
      const driver = await prisma.driver.findUnique({ where: { user_id: payload.userId } });
      if (driver) ws.driverId = driver.id;
    }

    // Register in connected clients map
    connectedClients.set(payload.userId, ws);

    console.log(`[WS] ${payload.role} connected: ${payload.userId}`);

    // Send welcome message
    send(ws, { type: 'connected', userId: payload.userId, role: payload.role, ts: new Date().toISOString() });

    // ─── Subscribe to relevant channels ────────────────────────────────────────────

    const unsubscribers: (() => void)[] = [];

    // Subscribe to personal notifications
    unsubscribers.push(
      eventBus.subscribe(CHANNELS.NOTIFICATION(payload.userId), (data) => {
        send(ws, data);
      })
    );

    if (payload.role === 'DRIVER' && ws.driverId) {
      // Drivers receive new ride requests
      unsubscribers.push(
        eventBus.subscribe(CHANNELS.RIDE_NEW(payload.userId), (data) => {
          send(ws, data);
        })
      );

      // Drivers receive bid accepted notifications
      unsubscribers.push(
        eventBus.subscribe(CHANNELS.BID_ACCEPTED(ws.driverId), (data) => {
          send(ws, data);
        })
      );
    }

    if (payload.role === 'RIDER') {
      // Riders subscribe to their active ride updates
      const activeRide = await prisma.ride.findFirst({
        where: {
          rider_id: payload.userId,
          status: { in: ['PENDING', 'BIDDING', 'ACCEPTED', 'DRIVER_ARRIVING', 'IN_PROGRESS'] },
        },
      });

      if (activeRide) {
        subscribeToRide(ws, activeRide.id, unsubscribers);
      }
    }

    // ─── Message Handler ────────────────────────────────────────────────────
    ws.on('message', async (rawData: Buffer) => {
      try {
        const message = JSON.parse(rawData.toString());
        const { type, data } = message;

        switch (type) {
          case 'driver:update-location': {
            if (ws.role !== 'DRIVER' || !ws.driverId) break;
            const { lat, lng, heading } = data;
            if (typeof lat !== 'number' || typeof lng !== 'number') break;

            // Update DB
            await prisma.driver.update({
              where: { id: ws.driverId },
              data: { lat, lng, heading: heading ?? 0 },
            });

            // If on active ride, broadcast location to rider
            const activeRide = await prisma.ride.findFirst({
              where: {
                driver_id: ws.driverId,
                status: { in: ['ACCEPTED', 'DRIVER_ARRIVING', 'IN_PROGRESS'] },
              },
            });

            if (activeRide) {
              eventBus.publish(CHANNELS.DRIVER_LOCATION(activeRide.id), {
                type: 'driver:location',
                rideId: activeRide.id,
                lat,
                lng,
                heading: heading ?? 0,
                ts: new Date().toISOString(),
              });
            }
            break;
          }

          case 'driver:toggle-status': {
            if (ws.role !== 'DRIVER' || !ws.driverId) break;
            const { is_online } = data;
            await prisma.driver.update({
              where: { id: ws.driverId },
              data: { is_online: !!is_online },
            });
            send(ws, { type: 'driver:status-updated', is_online: !!is_online });
            break;
          }

          case 'rider:subscribe-ride': {
            if (ws.role !== 'RIDER') break;
            const { ride_id } = data;
            // Verify rider owns this ride
            const ride = await prisma.ride.findFirst({
              where: { id: ride_id, rider_id: ws.userId },
            });
            if (ride) {
              subscribeToRide(ws, ride_id, unsubscribers);
              send(ws, { type: 'subscribed', channel: `ride:${ride_id}` });
            }
            break;
          }

          case 'ping': {
            send(ws, { type: 'pong', ts: new Date().toISOString() });
            break;
          }

          default:
            send(ws, { type: 'error', message: `Unknown event type: ${type}` });
        }
      } catch (err) {
        console.error('[WS] Message parse error:', err);
        send(ws, { type: 'error', message: 'Invalid message format' });
      }
    });

    // ─── Disconnect Handler ───────────────────────────────────────────────────
    ws.on('close', async () => {
      console.log(`[WS] ${payload.role} disconnected: ${payload.userId}`);
      connectedClients.delete(payload.userId);

      // Unsubscribe all event listeners
      unsubscribers.forEach((unsub) => unsub());

      // If driver disconnects, mark as offline after 60 seconds
      // (allow reconnect grace period)
      if (payload.role === 'DRIVER' && ws.driverId) {
        setTimeout(async () => {
          // Only set offline if still disconnected
          if (!connectedClients.has(payload.userId)) {
            try {
              await prisma.driver.update({
                where: { id: ws.driverId },
                data: { is_online: false },
              });
            } catch {
              // Driver may have been deleted
            }
          }
        }, 60000);
      }
    });

    ws.on('error', (err) => {
      console.error(`[WS] Error for ${payload.userId}:`, err.message);
    });
  });

  return wss;
}

/**
 * Subscribe a WebSocket client to a ride's real-time updates
 */
function subscribeToRide(ws: AuthenticatedSocket, rideId: string, unsubscribers: (() => void)[]): void {
  // Ride status updates
  unsubscribers.push(
    eventBus.subscribe(CHANNELS.RIDE_UPDATE(rideId), (data) => {
      send(ws, data);
    })
  );

  // Bid events (for riders)
  unsubscribers.push(
    eventBus.subscribe(CHANNELS.BID_RECEIVED(rideId), (data) => {
      send(ws, data);
    })
  );

  // Driver location updates
  unsubscribers.push(
    eventBus.subscribe(CHANNELS.DRIVER_LOCATION(rideId), (data) => {
      send(ws, data);
    })
  );
}

/**
 * Get count of connected WebSocket clients
 */
export const getConnectedCount = (): number => connectedClients.size;

/**
 * Send a message to a specific user via WebSocket
 */
export const sendToUser = (userId: string, data: object): void => {
  const client = connectedClients.get(userId);
  if (client) send(client, data);
};
