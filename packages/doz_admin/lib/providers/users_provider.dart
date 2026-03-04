import 'package:flutter/foundation.dart';
import 'package:doz_shared/doz_shared.dart';

class UsersProvider extends ChangeNotifier {
  final ApiClient _api;

  List<UserModel> _riders = [];
  List<UserModel> _filteredRiders = [];
  int _riderPage = 1;
  int _riderTotal = 0;
  bool _ridersLoading = false;
  String? _ridersError;
  String? _riderSearch;
  bool? _riderActiveFilter;

  static const int _pageSize = 20;

  UsersProvider({required ApiClient api}) : _api = api;

  List<UserModel> get riders => _filteredRiders;
  int get riderPage => _riderPage;
  int get riderTotal => _riderTotal;
  int get riderTotalPages => (_riderTotal / _pageSize).ceil().clamp(1, 9999);
  bool get ridersLoading => _ridersLoading;
  String? get ridersError => _ridersError;
  String? get riderSearch => _riderSearch;
  bool? get riderActiveFilter => _riderActiveFilter;

  Future<void> loadRiders({bool reset = false}) async {
    if (reset) {
      _riderPage = 1;
      _riders = [];
    }
    _ridersLoading = true;
    _ridersError = null;
    notifyListeners();
    try {
      final result = await _api.getAdminUsers(
        role: 'rider',
        page: _riderPage,
        limit: _pageSize,
        search: _riderSearch,
      );
      _riders = result;
      _riderTotal = result.length < _pageSize
          ? (_riderPage - 1) * _pageSize + result.length
          : _riderPage * _pageSize + 1;
      _applyRiderFilters();
    } on ApiException catch (e) {
      _ridersError = e.message;
    } catch (e) {
      _ridersError = 'Failed to load riders.';
    } finally {
      _ridersLoading = false;
      notifyListeners();
    }
  }

  void _applyRiderFilters() {
    _filteredRiders = _riders.where((u) {
      if (_riderActiveFilter != null && u.isActive != _riderActiveFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void setRiderSearch(String? query) {
    _riderSearch = (query?.isEmpty ?? true) ? null : query;
    loadRiders(reset: true);
  }

  void setRiderActiveFilter(bool? active) {
    _riderActiveFilter = active;
    _applyRiderFilters();
    notifyListeners();
  }

  Future<bool> blockUser(String userId, bool block) async {
    try {
      final updated = await _api.adminBlockUser(userId, block);
      // Update in local list
      final idx = _riders.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        _riders[idx] = updated;
        _applyRiderFilters();
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  void goToRiderPage(int page) {
    if (page < 1) return;
    _riderPage = page;
    loadRiders();
  }
}
