import 'dart:async';
import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

enum RidePhase {
  idle,
  incomingRequest,
  placingBid,
  waitingAcceptance,
  navigatingToPickup,
  atPickup,
  inTrip,
  completing,
  completed,
  ratingRider,
}

/// Manages current ride state for the driver.
class RideProvider extends ChangeNotifier {
  final ApiClient _api;
  final WebSocketService _ws;

  RidePhase _phase = RidePhase.idle;
  RideModel? _currentRide;
  BidModel? _currentBid;
  String? _errorMessage;
  bool _isLoading = false;

  Timer? _requestTimer;
  int _requestTimerSeconds = 30;

  Timer? _tripTimer;
  int _tripSeconds = 0;

  StreamSubscription? _rideUpdateSub;
  StreamSubscription? _bidAcceptedSub;

  RideProvider({
    required ApiClient api,
    required WebSocketService ws,
  })  : _api = api,
        _ws = ws;

  RidePhase get phase => _phase;
  RideModel? get currentRide => _currentRide;
  BidModel? get currentBid => _currentBid;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  int get requestTimerSeconds => _requestTimerSeconds;
  int get tripSeconds => _tripSeconds;

  String get tripDuration {
    final m = _tripSeconds ~/ 60;
    final s = _tripSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get hasActiveRide =>
      _phase != RidePhase.idle &&
      _phase != RidePhase.incomingRequest &&
      _phase != RidePhase.placingBid;

  void startListening() {
    _rideUpdateSub?.cancel();
    _bidAcceptedSub?.cancel();
    _rideUpdateSub = _ws.onRideUpdate.listen(_onRideUpdate);
    _bidAcceptedSub = _ws.onBidAccepted.listen(_onBidAccepted);
  }

  void stopListening() {
    _rideUpdateSub?.cancel();
    _bidAcceptedSub?.cancel();
  }

  void onNewRideRequest(RideModel ride) {
    _currentRide = ride;
    _phase = RidePhase.incomingRequest;
    _requestTimerSeconds = 30;
    _startRequestTimer();
    notifyListeners();
  }

  void _startRequestTimer() {
    _requestTimer?.cancel();
    _requestTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _requestTimerSeconds--;
      notifyListeners();
      if (_requestTimerSeconds <= 0) {
        timer.cancel();
        declineRequest();
      }
    });
  }

  void declineRequest() {
    _requestTimer?.cancel();
    _currentRide = null;
    _phase = RidePhase.idle;
    notifyListeners();
  }

  void openBidScreen() {
    _requestTimer?.cancel();
    _phase = RidePhase.placingBid;
    notifyListeners();
  }

  Future<bool> placeBid(double amount) async {
    if (_currentRide == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentBid = await _api.placeBid(
        rideId: _currentRide!.id,
        amount: amount,
      );
      _phase = RidePhase.waitingAcceptance;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelBid() async {
    _currentBid = null;
    _currentRide = null;
    _phase = RidePhase.idle;
    notifyListeners();
    return true;
  }

  void _onBidAccepted(BidModel bid) {
    if (_currentBid != null && bid.id == _currentBid!.id) {
      _currentBid = bid;
      _phase = RidePhase.navigatingToPickup;
      notifyListeners();
    }
  }

  void _onRideUpdate(RideModel ride) {
    if (ride.status == RideStatus.pending &&
        ride.driverId == null &&
        _phase == RidePhase.idle) {
      onNewRideRequest(ride);
      return;
    }
    if (_currentRide != null && ride.id == _currentRide!.id) {
      _currentRide = ride;
      notifyListeners();
    }
  }

  Future<bool> confirmArrival() async {
    if (_currentRide == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      _currentRide = await _api.updateRideStatus(
        _currentRide!.id,
        RideStatus.driverArriving.toJson(),
      );
      _phase = RidePhase.atPickup;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> startRide() async {
    if (_currentRide == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      _currentRide = await _api.updateRideStatus(
        _currentRide!.id,
        RideStatus.inProgress.toJson(),
      );
      _phase = RidePhase.inTrip;
      _startTripTimer();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeRide() async {
    if (_currentRide == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      _currentRide = await _api.updateRideStatus(
        _currentRide!.id,
        RideStatus.completed.toJson(),
      );
      _stopTripTimer();
      _phase = RidePhase.completed;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelCurrentRide({String? reason}) async {
    if (_currentRide == null) return false;
    _isLoading = true;
    notifyListeners();
    try {
      await _api.cancelRide(_currentRide!.id, reason: reason);
      _stopTripTimer();
      _resetState();
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rateRider({
    required int stars,
    List<String> tags = const [],
    String? comment,
  }) async {
    if (_currentRide?.rider == null) return false;
    try {
      await _api.submitRating(
        rideId: _currentRide!.id,
        toUserId: _currentRide!.riderId,
        stars: stars,
        tags: tags,
        comment: comment,
      );
      _resetState();
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }

  void proceedToRating() {
    _phase = RidePhase.ratingRider;
    notifyListeners();
  }

  void skipRating() {
    _resetState();
  }

  void _startTripTimer() {
    _tripSeconds = 0;
    _tripTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tripSeconds++;
      notifyListeners();
    });
  }

  void _stopTripTimer() {
    _tripTimer?.cancel();
    _tripTimer = null;
  }

  void _resetState() {
    _currentRide = null;
    _currentBid = null;
    _phase = RidePhase.idle;
    _tripSeconds = 0;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _requestTimer?.cancel();
    _tripTimer?.cancel();
    stopListening();
    super.dispose();
  }
}
