import 'dart:math' as math;

/// A geographic coordinate (latitude, longitude).
class LatLngModel {
  final double lat;
  final double lng;

  const LatLngModel({required this.lat, required this.lng});

  factory LatLngModel.fromJson(Map<String, dynamic> json) {
    return LatLngModel(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};

  LatLngModel copyWith({double? lat, double? lng}) {
    return LatLngModel(lat: lat ?? this.lat, lng: lng ?? this.lng);
  }

  /// Calculate distance in kilometers to another point using Haversine formula.
  double distanceTo(LatLngModel other) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(other.lat - lat);
    final dLng = _toRadians(other.lng - lng);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat)) *
            math.cos(_toRadians(other.lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LatLngModel && other.lat == lat && other.lng == lng);

  @override
  int get hashCode => Object.hash(lat, lng);

  @override
  String toString() => 'LatLng($lat, $lng)';
}

/// Result from a place search or geocoding.
class PlaceResult {
  final String placeId;
  final String name;
  final String address;
  final LatLngModel location;
  final String? city;
  final String? country;

  const PlaceResult({
    required this.placeId,
    required this.name,
    required this.address,
    required this.location,
    this.city,
    this.country,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    return PlaceResult(
      placeId: json['placeId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      location: LatLngModel.fromJson(
          json['location'] as Map<String, dynamic>? ?? {}),
      city: json['city'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'name': name,
      'address': address,
      'location': location.toJson(),
      if (city != null) 'city': city,
      if (country != null) 'country': country,
    };
  }

  PlaceResult copyWith({
    String? placeId,
    String? name,
    String? address,
    LatLngModel? location,
    String? city,
    String? country,
  }) {
    return PlaceResult(
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      address: address ?? this.address,
      location: location ?? this.location,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }

  @override
  String toString() => 'PlaceResult(name: $name, address: $address)';
}

/// Route information between two points.
class RouteInfo {
  final double distanceKm;
  final int durationMin;
  final List<LatLngModel> polylinePoints;
  final String? encodedPolyline;

  const RouteInfo({
    required this.distanceKm,
    required this.durationMin,
    this.polylinePoints = const [],
    this.encodedPolyline,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      durationMin: json['durationMin'] as int? ?? 0,
      polylinePoints: (json['polylinePoints'] as List<dynamic>?)
              ?.map((e) =>
                  LatLngModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      encodedPolyline: json['encodedPolyline'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distanceKm': distanceKm,
      'durationMin': durationMin,
      'polylinePoints': polylinePoints.map((p) => p.toJson()).toList(),
      if (encodedPolyline != null) 'encodedPolyline': encodedPolyline,
    };
  }

  RouteInfo copyWith({
    double? distanceKm,
    int? durationMin,
    List<LatLngModel>? polylinePoints,
    String? encodedPolyline,
  }) {
    return RouteInfo(
      distanceKm: distanceKm ?? this.distanceKm,
      durationMin: durationMin ?? this.durationMin,
      polylinePoints: polylinePoints ?? this.polylinePoints,
      encodedPolyline: encodedPolyline ?? this.encodedPolyline,
    );
  }

  @override
  String toString() =>
      'RouteInfo(distanceKm: $distanceKm, durationMin: $durationMin)';
}
