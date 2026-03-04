import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Manages incoming driver bids for a ride request.
class BidsProvider extends ChangeNotifier {
  final ApiClient _api;

  BidsProvider(this._api);

  List<BidModel> _bids = [];
  bool _loading = false;
  String? _error;

  List<BidModel> get bids => _bids;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> fetchBids(String rideId) async {
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

  Future<bool> acceptBid(String rideId, String bidId) async {
    try {
      await _api.post('/rides/$rideId/bids/$bidId/accept', {});
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearBids() {
    _bids = [];
    notifyListeners();
  }
}
