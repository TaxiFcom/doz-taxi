import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';
import '../models/location_model.dart';

/// Manages the current ride request flow for the rider.
class RideProvider extends ChangeNotifier {
  final ApiClient _api;

  RideProvider(this._api);

  // Booking state
  LocationModel? _pickup;
  LocationModel? _dropoff;
  VehicleType _vehicleType = VehicleType.economy;
  double? _offeredPrice;

  // Ride state
  RideModel? _currentRide;
  bool _loading = false;
  String? _error;

  LocationModel? get pickup => _pickup;
  LocationModel? get dropoff => _dropoff;
  VehicleType get vehicleType => _vehicleType;
  double? get offeredPrice => _offeredPrice;
  RideModel? get currentRide => _currentRide;
  bool get isLoading => _loading;
  String? get error => _error;

  void setPickup(LocationModel loc) {
    _pickup = loc;
    notifyListeners();
  }

  void setDropoff(LocationModel loc) {
    _dropoff = loc;
    notifyListeners();
  }

  void setVehicleType(VehicleType type) {
    _vehicleType = type;
    notifyListeners();
  }

  void setOfferedPrice(double price) {
    _offeredPrice = price;
    notifyListeners();
  }

  /// Estimate fare before requesting.
  Future<FareEstimate?> estimateFare() async {
    if (_pickup == null || _dropoff == null) return null;
    try {
      final res = await _api.post('/rides/estimate', {
        'pickup': _pickup!.toJson(),
        'dropoff': _dropoff!.toJson(),
        'vehicleType': _vehicleType.name,
      });
      return FareEstimate.fromJson(res);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Create a new ride request.
  Future<bool> requestRide() async {
    if (_pickup == null || _dropoff == null) return false;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final body = {
        'pickup': _pickup!.toJson(),
        'dropoff': _dropoff!.toJson(),
        'vehicleType': _vehicleType.name,
        if (_offeredPrice != null) 'offeredPrice': _offeredPrice,
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

  Future<void> loadCurrentRide() async {
    try {
      final res = await _api.get('/rides/current');
      if (res != null) {
        _currentRide = RideModel.fromJson(res);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> cancelRide() async {
    if (_currentRide == null) return false;
    _loading = true;
    notifyListeners();
    try {
      await _api.post('/rides/${_currentRide!.id}/cancel', {});
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

  void clearRide() {
    _currentRide = null;
    _pickup = null;
    _dropoff = null;
    _offeredPrice = null;
    notifyListeners();
  }
}
