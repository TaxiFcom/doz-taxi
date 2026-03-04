type EventHandler = (data: any) => void;

class EventBus {
  private channels: Map<string, Set<EventHandler>> = new Map();

  subscribe(channel: string, handler: EventHandler): () => void {
    if (!this.channels.has(channel)) {
      this.channels.set(channel, new Set());
    }
    this.channels.get(channel)!.add(handler);
    return () => { this.channels.get(channel)?.delete(handler); };
  }

  publish(channel: string, data: any): void {
    const handlers = this.channels.get(channel);
    if (handlers) {
      handlers.forEach((handler) => {
        try { handler(data); } catch (err) {
          console.error(`[EventBus] Error in handler for channel ${channel}:`, err);
        }
      });
    }
  }

  unsubscribeAll(channel: string): void { this.channels.delete(channel); }
  listChannels(): string[] { return Array.from(this.channels.keys()); }
}

export const eventBus = new EventBus();

export const CHANNELS = {
  RIDE_NEW: (userId: string) => `ride:new:${userId}`,
  RIDE_UPDATE: (rideId: string) => `ride:update:${rideId}`,
  BID_RECEIVED: (rideId: string) => `bid:received:${rideId}`,
  BID_ACCEPTED: (driverId: string) => `bid:accepted:${driverId}`,
  DRIVER_LOCATION: (rideId: string) => `driver:location:${rideId}`,
  NOTIFICATION: (userId: string) => `notification:${userId}`,
  BROADCAST_DRIVERS: 'broadcast:drivers',
} as const;
