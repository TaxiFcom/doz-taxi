const EARTH_RADIUS_KM = 6371;

export const toRad = (degrees: number): number => (degrees * Math.PI) / 180;

export const haversineDistance = (lat1: number, lng1: number, lat2: number, lng2: number): number => {
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return EARTH_RADIUS_KM * c;
};

export const estimatePrice = (distanceKm: number, durationMin: number, baseFare: number, perKm: number, perMin: number, minFare: number): number => {
  const calculated = baseFare + distanceKm * perKm + durationMin * perMin;
  return Math.max(calculated, minFare);
};

export const estimateDuration = (distanceKm: number, avgSpeedKmh = 30): number => {
  return (distanceKm / avgSpeedKmh) * 60;
};

export const isWithinRadius = (lat1: number, lng1: number, lat2: number, lng2: number, radiusKm: number): boolean => {
  return haversineDistance(lat1, lng1, lat2, lng2) <= radiusKm;
};

export interface DriverWithDistance {
  id: string;
  lat: number;
  lng: number;
  distance?: number;
  [key: string]: any;
}

export const sortDriversByDistance = <T extends DriverWithDistance>(drivers: T[], lat: number, lng: number): (T & { distance: number })[] => {
  return drivers
    .map((d) => ({ ...d, distance: haversineDistance(lat, lng, d.lat, d.lng) }))
    .sort((a, b) => a.distance - b.distance);
};

export const getBoundingBox = (lat: number, lng: number, radiusKm: number) => {
  const latDelta = radiusKm / EARTH_RADIUS_KM * (180 / Math.PI);
  const lngDelta = radiusKm / (EARTH_RADIUS_KM * Math.cos(toRad(lat))) * (180 / Math.PI);
  return { minLat: lat - latDelta, maxLat: lat + latDelta, minLng: lng - lngDelta, maxLng: lng + lngDelta };
};
