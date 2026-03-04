import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Manages incoming driver bids for a ride request.
class BidsProvider extends ChangeNotifier {
  final ApiClient _api;

  BidsProvider(this._api);

  List<BidModel> _bids = [];
  bool _loading = false;
  String? _error;
  String _sortBy = 'price'; // 'price' or 'rating'
  String? _currentRideId;

  // ===================== GETTERS =====================

  List<BidModel> get bids {
    final sorted = List<BidModel>.from(_bids);
    if (_sortBy == 'rating') {
      sorted.sort((a, b) {
        final ratingA = a.driver?.rating ?? 0.0;
        final ratingB = b.driver?.rating ?? 0.0;
        return ratingB.compareTo(ratingA); // Highest first
      });
    } else {
      sorted.sort((a, b) => a.amount.compareTo(b.amount)); // Lowest first
    }
    return sorted;
  }

  bool get isLoading => _loading;
  bool get loading => _loading;
  String? get error => _error;
  String get sortBy => _sortBy;

  /// Count of bids with pending status.
  int get pendingCount =>
      _bids.where((b) => b.status == BidStatus.pending).length;

  // ===================== SORT =====================

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  // ===================== API =====================

  /// Load (fetch) bids for a ride.
  Future<void> loadBids(String rideId) async {
    _currentRideId = rideId;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.get('/rides/$rideId/bids');
      _bids = (res as List).map((b) => BidModel.fromJson(b)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Alias for backward compatibility.
  Future<void> fetchBids(String rideId) => loadBids(rideId);

  /// Accept a bid (uses stored rideId if available).
  Future<bool> acceptBid(String bidId) async {
    final rideId = _currentRideId ?? '';
    if (rideId.isEmpty) return false;
    try {
      await _api.post('/rides/$rideId/bids/$bidId/accept', {});
      // Update the bid status locally.
      final idx = _bids.indexWhere((b) => b.id == bidId);
      if (idx != -1) {
        _bids[idx] = _bids[idx].copyWith(status: BidStatus.accepted);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Reject a bid.
  Future<bool> rejectBid(String bidId) async {
    final rideId = _currentRideId ?? '';
    if (rideId.isEmpty) return false;
    try {
      await _api.post('/rides/$rideId/bids/$bidId/reject', {});
      // Update the bid status locally.
      final idx = _bids.indexWhere((b) => b.id == bidId);
      if (idx != -1) {
        _bids[idx] = _bids[idx].copyWith(status: BidStatus.rejected);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearBids() {
    _bids = [];
    _currentRideId = null;
    notifyListeners();
  }
}
