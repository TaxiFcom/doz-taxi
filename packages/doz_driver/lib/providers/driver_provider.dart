import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:doz_shared/doz_shared.dart';

enum DriverStatus { offline, goingOnline, online, busy }

class DriverProvider extends ChangeNotifier {
  final ApiClient _api;
  final WebSocketService _ws;

  DriverModel? _driverModel;
  DriverStatus _status = DriverStatus.offline;
  Position? _currentPosition;
  String? _errorMessage;
  bool _isLoading = false;

  StreamSubscription<Position>? _positionSubscription;
  Timer? _locationBroadcastTimer;

  static const double _ammanLat = AppConstants.defaultLat;
  static const double _ammanLng = AppConstants.defaultLng;

  DriverProvider({
    required ApiClient api,
    required WebSocketService ws,
  })  : _api = api,
        _ws = ws;

  DriverModel? get driverModel => _driverModel;
  DriverStatus get status => _status;
  bool get isOnline => _status == DriverStatus.online || _status == DriverStatus.busy;
  bool get isOffline => _status == DriverStatus.offline;
  bool get isBusy => _status == DriverStatus.busy;
  Position? get currentPosition => _currentPosition;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  double get currentLat => _currentPosition?.latitude ?? _ammanLat;
  double get currentLng => _currentPosition?.longitude ?? _ammanLng;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      _driverModel = await _api.getDriverProfile();
      if (_driverModel!.isOnline) {
        _status = _driverModel!.isBusy ? DriverStatus.busy : DriverStatus.online;
      }
    } catch (e) {}
    await _initLocation();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _initLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> goOnline() async {
    if (_status == DriverStatus.online || _status == DriverStatus.busy) return true;
    _status = DriverStatus.goingOnline;
    _errorMessage = null;
    notifyListeners();
    try {
      _driverModel = await _api.toggleOnlineStatus(true);
      _status = DriverStatus.online;
      await _ws.connect();
      _startLocationTracking();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      _status = DriverStatus.offline;
      notifyListeners();
      return false;
    }
  }

  Future<bool> goOffline() async {
    if (_status == DriverStatus.offline) return true;
    _isLoading = true;
    notifyListeners();
    try {
      _driverModel = await _api.toggleOnlineStatus(false);
      _status = DriverStatus.offline;
      _stopLocationTracking();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setBusy(bool busy) {
    if (busy && _status == DriverStatus.online) {
      _status = DriverStatus.busy;
    } else if (!busy && _status == DriverStatus.busy) {
      _status = DriverStatus.online;
    }
    notifyListeners();
  }

  void _startLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((position) {
      _currentPosition = position;
      notifyListeners();
    });
    _locationBroadcastTimer?.cancel();
    _locationBroadcastTimer = Timer.periodic(
      AppConstants.locationUpdateInterval,
      (_) => _broadcastLocation(),
    );
  }

  void _stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _locationBroadcastTimer?.cancel();
    _locationBroadcastTimer = null;
  }

  void _broadcastLocation() {
    if (_currentPosition != null && _ws.isConnected) {
      _ws.sendLocationUpdate(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        heading: _currentPosition!.heading,
      );
    }
  }

  void updateDriverModel(DriverModel model) {
    _driverModel = model;
    notifyListeners();
  }

  Future<void> refreshDriverProfile() async {
    try {
      _driverModel = await _api.getDriverProfile();
      notifyListeners();
    } catch (_) {}
  }

  @override
  void dispose() {
    _stopLocationTracking();
    super.dispose();
  }
}
