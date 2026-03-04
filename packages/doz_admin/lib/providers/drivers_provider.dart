import 'package:flutter/foundation.dart';
import 'package:doz_shared/doz_shared.dart';

enum DriverStatusFilter { all, pending, active, blocked }

class DriversProvider extends ChangeNotifier {
  final ApiClient _api;

  List<DriverModel> _drivers = [];
  List<DriverModel> _filteredDrivers = [];
  int _page = 1;
  int _total = 0;
  bool _isLoading = false;
  String? _error;
  String? _searchQuery;
  DriverStatusFilter _statusFilter = DriverStatusFilter.all;

  static const int _pageSize = 20;

  DriversProvider({required ApiClient api}) : _api = api;

  List<DriverModel> get drivers => _filteredDrivers;
  List<DriverModel> get pendingDrivers =>
      _drivers.where((d) => d.user != null && !d.user!.isVerified).toList();
  int get page => _page;
  int get total => _total;
  int get totalPages => (_total / _pageSize).ceil().clamp(1, 9999);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get searchQuery => _searchQuery;
  DriverStatusFilter get statusFilter => _statusFilter;

  Future<void> loadDrivers({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _drivers = [];
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final usersResult = await _api.getAdminUsers(
        role: 'driver',
        page: _page,
        limit: _pageSize,
        search: _searchQuery,
      );
      // Convert UserModel list to DriverModel list with embedded user
      _drivers = usersResult.map((u) {
        return DriverModel(
          id: u.id,
          userId: u.id,
          user: u,
          licenseNumber: '',
          vehicleType: '',
          vehicleModel: '',
          vehicleColor: '',
          plateNumber: '',
          isOnline: false,
          isBusy: false,
          rating: 0,
          totalRides: 0,
          totalEarnings: 0,
        );
      }).toList();
      _total = usersResult.length < _pageSize
          ? (_page - 1) * _pageSize + usersResult.length
          : _page * _pageSize + 1;
      _applyFilters();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load drivers.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyFilters() {
    _filteredDrivers = _drivers.where((d) {
      switch (_statusFilter) {
        case DriverStatusFilter.pending:
          return d.user != null && !d.user!.isVerified && d.user!.isActive;
        case DriverStatusFilter.active:
          return d.user != null && d.user!.isActive && d.user!.isVerified;
        case DriverStatusFilter.blocked:
          return d.user != null && !d.user!.isActive;
        case DriverStatusFilter.all:
          return true;
      }
    }).where((d) {
      if (_searchQuery == null || _searchQuery!.isEmpty) return true;
      final q = _searchQuery!.toLowerCase();
      final name = d.user?.name.toLowerCase() ?? '';
      final phone = d.user?.phone.toLowerCase() ?? '';
      return name.contains(q) || phone.contains(q) || d.plateNumber.toLowerCase().contains(q);
    }).toList();
  }

  void setStatusFilter(DriverStatusFilter filter) {
    _statusFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String? query) {
    _searchQuery = (query?.isEmpty ?? true) ? null : query;
    _applyFilters();
    notifyListeners();
  }

  Future<bool> approveDriver(String driverId) async {
    try {
      await _api.adminApproveDriver(driverId);
      await loadDrivers(reset: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> blockDriver(String userId, bool block) async {
    try {
      await _api.adminBlockUser(userId, block);
      await loadDrivers(reset: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  void goToPage(int page) {
    if (page < 1) return;
    _page = page;
    loadDrivers();
  }
}
