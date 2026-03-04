import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:doz_shared/doz_shared.dart';

/// Manages device GPS location for the rider.
class LocationProvider extends ChangeNotifier {
  Position? _position;
  bool _loading = false;
  String? _error;

  Position? get position => _position;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      _error = 'Location permissions are permanently denied.';
      notifyListeners();
    }
  }

  Future<void> fetchCurrentLocation() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  LatLng? get latLng => _position == null
      ? null
      : LatLng(_position!.latitude, _position!.longitude);
}
