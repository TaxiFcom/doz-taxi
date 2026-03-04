import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';
import '../models/location_model.dart';

/// Manages the current ride request flow for the rider.
class RideProvider extends ChangeNotifier {
  final ApiClient _api;

  RideProvider(this._api);

  // --- Booking state ---
  LocationModel? _pickupLocation;
  LocationModel? _dropoffLocation;
  String? _selectedVehicleType;
  double _suggestedPrice = 3.0;
  List<VehicleTypeModel> _vehicleTypes = [];

  // --- Ride state ---
  RideModel? _currentRide;
  bool _loading = false;
  String? _error;

  // --- Ride history ---
  List<RideModel> _rideHistory = [];

  // ===================== GETTERS =====================

  LocationModel? get pickupLocation => _pickupLocation;
  LocationModel? get dropoffLocation => _dropoffLocation;
  String? get selectedVehicleType => _selectedVehicleType;
  double get suggestedPrice => _suggestedPrice;
  List<VehicleTypeModel> get vehicleTypes => _vehicleTypes;
  RideModel? get currentRide => _currentRide;
  bool get isLoading => _loading;
  bool get loading => _loading;
  String? get error => _error;
  List<RideModel> get rideHistory => _rideHistory;

  /// Legacy getters for backward compatibility.
  LocationModel? get pickup => _pickupLocation;
  LocationModel? get dropoff => _dropoffLocation;
  VehicleType get vehicleType {
    switch (_selectedVehicleType) {
      case 'comfort':
        return VehicleType.comfort;
      case 'business':
        return VehicleType.business;
      default:
        return VehicleType.economy;
    }
  }

  double? get offeredPrice => _suggestedPrice;

  // ===================== SETTERS =====================

  void setPickupLocation(LocationModel loc) {
    _pickupLocation = loc;
    notifyListeners();
  }

  void setDropoffLocation(LocationModel loc) {
    _dropoffLocation = loc;
    notifyListeners();
  }

  /// Alias for backward compatibility.
  void setPickup(LocationModel loc) => setPickupLocation(loc);
  void setDropoff(LocationModel loc) => setDropoffLocation(loc);

  void setVehicleType(String typeId) {
    _selectedVehicleType = typeId;
    notifyListeners();
  }

  void selectVehicleType(String typeId) => setVehicleType(typeId);

  void setSuggestedPrice(double price) {
    _suggestedPrice = price;
    notifyListeners();
  }

  void setOfferedPrice(double price) => setSuggestedPrice(price);

  // ===================== VEHICLE TYPES =====================

  /// Load available vehicle types from the API.
  Future<void> loadVehicleTypes() async {
    try {
      final res = await _api.get('/vehicle-types');
      if (res is List) {
        _vehicleTypes =
            res.map((v) => VehicleTypeModel.fromJson(v)).toList();
      } else {
        // Fallback defaults if API not ready.
        _vehicleTypes = [
          VehicleTypeModel(
            id: 'economy',
            nameEn: 'Economy',
            nameAr: '\u0627\u0642\u062a\u0635\u0627\u062f\u064a',
            baseFare: 1.5,
            perKm: 0.5,
            perMin: 0.15,
            minFare: 1.5,
            icon: 'car_economy',
          ),
          VehicleTypeModel(
            id: 'comfort',
            nameEn: 'Comfort',
            nameAr: '\u0645\u0631\u064a\u062d',
            baseFare: 2.5,
            perKm: 0.7,
            perMin: 0.2,
            minFare: 2.5,
            icon: 'car_comfort',
          ),
          VehicleTypeModel(
            id: 'business',
            nameEn: 'Business',
            nameAr: '\u0623\u0639\u0645\u0627\u0644',
            baseFare: 4.0,
            perKm: 1.0,
            perMin: 0.3,
            minFare: 4.0,
            icon: 'car_business',
          ),
        ];
      }
      notifyListeners();
    } catch (_) {
      // Provide fallback vehicle types on error.
      _vehicleTypes = [
        VehicleTypeModel(
          id: 'economy',
          nameEn: 'Economy',
          nameAr: '\u0627\u0642\u062a\u0635\u0627\u062f\u064a',
          baseFare: 1.5,
          perKm: 0.5,
          perMin: 0.15,
          minFare: 1.5,
          icon: 'car_economy',
        ),
        VehicleTypeModel(
          id: 'comfort',
          nameEn: 'Comfort',
          nameAr: '\u0645\u0631\u064a\u062d',
          baseFare: 2.5,
          perKm: 0.7,
          perMin: 0.2,
          minFare: 2.5,
          icon: 'car_comfort',
        ),
        VehicleTypeModel(
          id: 'business',
          nameEn: 'Business',
          nameAr: '\u0623\u0639\u0645\u0627\u0644',
          baseFare: 4.0,
          perKm: 1.0,
          perMin: 0.3,
          minFare: 4.0,
          icon: 'car_business',
        ),
      ];
      notifyListeners();
    }
  }

  // ===================== FARE ESTIMATION =====================

  /// Estimate fare before requesting.
  /// Returns a map with 'baseFare', 'estimatedPrice', 'distanceKm', 'durationMin'.
  Future<Map<String, dynamic>?> estimateFare() async {
    if (_pickupLocation == null || _dropoffLocation == null) return null;
    try {
      final res = await _api.post('/rides/estimate', {
        'pickupLat': _pickupLocation!.lat,
        'pickupLng': _pickupLocation!.lng,
        'dropoffLat': _dropoffLocation!.lat,
        'dropoffLng': _dropoffLocation!.lng,
        'vehicleType': _selectedVehicleType ?? 'economy',
      });
      if (res is Map<String, dynamic>) {
        _suggestedPrice =
            (res['estimatedPrice'] as num?)?.toDouble() ?? _suggestedPrice;
        notifyListeners();
        return res;
      }
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ===================== RIDE LIFECYCLE =====================

  /// Create a new ride request with explicit named parameters.
  Future<bool> createRide({
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffAddress,
    required double suggestedPrice,
    String vehicleType = 'economy',
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final body = {
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'pickupAddress': pickupAddress,
        'dropoffLat': dropoffLat,
        'dropoffLng': dropoffLng,
        'dropoffAddress': dropoffAddress,
        'suggestedPrice': suggestedPrice,
        'vehicleType': vehicleType,
      };
      final res = await _api.post('/rides', body);
      _currentRide = RideModel.fromJson(res);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Legacy requestRide() \u2014 calls createRide with current state.
  Future<bool> requestRide() async {
    if (_pickupLocation == null || _dropoffLocation == null) return false;
    return createRide(
      pickupLat: _pickupLocation!.lat,
      pickupLng: _pickupLocation!.lng,
      pickupAddress: _pickupLocation!.address,
      dropoffLat: _dropoffLocation!.lat,
      dropoffLng: _dropoffLocation!.lng,
      dropoffAddress: _dropoffLocation!.address,
      suggestedPrice: _suggestedPrice,
      vehicleType: _selectedVehicleType ?? 'economy',
    );
  }

  Future<void> loadCurrentRide() async {
    try {
      final res = await _api.get('/rides/current');
      if (res != null) {
        _currentRide = RideModel.fromJson(res);
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Cancel current ride with an optional reason.
  Future<bool> cancelRide({String? reason}) async {
    if (_currentRide == null) return false;
    _loading = true;
    notifyListeners();
    try {
      await _api.post('/rides/${_currentRide!.id}/cancel', {
        if (reason != null) 'reason': reason,
      });
      _currentRide = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Rate the driver for a given ride.
  Future<bool> rateDriver(String rideId, int rating, String? comment) async {
    try {
      await _api.post('/rides/$rideId/rating', {
        'rating': rating,
        if (comment != null) 'comment': comment,
      });
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ===================== RIDE HISTORY =====================

  /// Load ride history for the rider.
  Future<void> loadRideHistory() async {
    _loading = true;
    notifyListeners();
    try {
      final res = await _api.get('/rides/history');
      if (res is List) {
        _rideHistory =
            res.map((r) => RideModel.fromJson(r)).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ===================== RESET =====================

  void clearRide() {
    _currentRide = null;
    _pickupLocation = null;
    _dropoffLocation = null;
    _suggestedPrice = 3.0;
    _selectedVehicleType = null;
    notifyListeners();
  }
}
