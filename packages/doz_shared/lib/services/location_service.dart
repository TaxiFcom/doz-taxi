import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:logger/logger.dart';
import '../models/location_model.dart';

/// Service for device location, geocoding, and distance calculation.
class LocationService {
  static LocationService? _instance;
  final Logger _logger = Logger();

  StreamSubscription<Position>? _positionSubscription;
  final StreamController<LatLngModel> _locationController =
      StreamController<LatLngModel>.broadcast();

  Position? _lastPosition;

  LocationService._();

  static LocationService getInstance() {
    _instance ??= LocationService._();
    return _instance!;
  }

  Stream<LatLngModel> get locationStream => _locationController.stream;
  LatLngModel? get lastLocation => _lastPosition != null
      ? LatLngModel(
          lat: _lastPosition!.latitude, lng: _lastPosition!.longitude)
      : null;

  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _logger.w('[Location] Location services disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _logger.w('[Location] Permission denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _logger.w('[Location] Permission permanently denied');
      return false;
    }

    return true;
  }

  Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<LatLngModel?> getCurrentLocation() async {
    final hasPerms = await requestPermission();
    if (!hasPerms) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      _lastPosition = position;
      return LatLngModel(lat: position.latitude, lng: position.longitude);
    } catch (e) {
      _logger.e('[Location] Failed to get position: $e');
      return null;
    }
  }

  Future<void> startWatching({
    int distanceFilter = 10,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    final hasPerms = await requestPermission();
    if (!hasPerms) return;

    await _positionSubscription?.cancel();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(
      (position) {
        _lastPosition = position;
        _locationController.add(
          LatLngModel(lat: position.latitude, lng: position.longitude),
        );
      },
      onError: (e) => _logger.e('[Location] Stream error: $e'),
    );

    _logger.i('[Location] Started watching');
  }

  Future<void> stopWatching() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _logger.i('[Location] Stopped watching');
  }

  Future<String?> reverseGeocode(LatLngModel location) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        location.lat,
        location.lng,
      );

      if (placemarks.isEmpty) return null;

      final p = placemarks.first;
      final parts = <String>[];

      if (p.street != null && p.street!.isNotEmpty) parts.add(p.street!);
      if (p.subLocality != null && p.subLocality!.isNotEmpty) {
        parts.add(p.subLocality!);
      }
      if (p.locality != null && p.locality!.isNotEmpty) {
        parts.add(p.locality!);
      }

      return parts.isEmpty ? null : parts.join(', ');
    } catch (e) {
      _logger.e('[Location] Reverse geocoding failed: $e');
      return null;
    }
  }

  Future<LatLngModel?> geocodeAddress(String address) async {
    try {
      final locations = await geocoding.locationFromAddress(address);
      if (locations.isEmpty) return null;
      return LatLngModel(
        lat: locations.first.latitude,
        lng: locations.first.longitude,
      );
    } catch (e) {
      _logger.e('[Location] Geocoding failed: $e');
      return null;
    }
  }

  Future<PlaceResult?> reverseGeocodeToPlace(LatLngModel location) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        location.lat,
        location.lng,
      );

      if (placemarks.isEmpty) return null;

      final p = placemarks.first;
      final nameParts = <String>[];
      if (p.street != null && p.street!.isNotEmpty) {
        nameParts.add(p.street!);
      }
      if (p.subLocality != null && p.subLocality!.isNotEmpty) {
        nameParts.add(p.subLocality!);
      }
      final name =
          nameParts.isNotEmpty ? nameParts.join(', ') : 'Unknown';

      final addrParts = <String>[];
      if (nameParts.isNotEmpty) addrParts.addAll(nameParts);
      if (p.locality != null && p.locality!.isNotEmpty) {
        addrParts.add(p.locality!);
      }
      if (p.country != null && p.country!.isNotEmpty) {
        addrParts.add(p.country!);
      }

      return PlaceResult(
        placeId: '${location.lat}_${location.lng}',
        name: name,
        address: addrParts.join(', '),
        location: location,
        city: p.locality,
        country: p.country,
      );
    } catch (e) {
      _logger.e('[Location] Reverse geocode to place failed: $e');
      return null;
    }
  }

  double calculateDistanceMeters(LatLngModel from, LatLngModel to) {
    return Geolocator.distanceBetween(
      from.lat,
      from.lng,
      to.lat,
      to.lng,
    );
  }

  double calculateDistanceKm(LatLngModel from, LatLngModel to) {
    return calculateDistanceMeters(from, to) / 1000.0;
  }

  double calculateBearing(LatLngModel from, LatLngModel to) {
    return Geolocator.bearingBetween(
      from.lat,
      from.lng,
      to.lat,
      to.lng,
    );
  }

  void dispose() {
    _positionSubscription?.cancel();
    _locationController.close();
  }
}
