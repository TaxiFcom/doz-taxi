import 'package:flutter/foundation.dart';
import 'package:doz_shared/doz_shared.dart';

class RidesProvider extends ChangeNotifier {
  final ApiClient _api;

  List<RideModel> _rides = [];
  int _totalCount = 0;
  int _currentPage = 1;
  static const int _pageSize = 20;

  bool _isLoading = false;
  String? _error;
  String? _statusFilter;
  String? _searchQuery;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _paymentMethodFilter;

  RidesProvider({required ApiClient api}) : _api = api;

  List<RideModel> get rides => _rides;
  int get totalCount => _totalCount;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages => (_totalCount / _pageSize).ceil();
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get statusFilter => _statusFilter;
  String? get searchQuery => _searchQuery;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  String? get paymentMethodFilter => _paymentMethodFilter;

  Future<void> loadRides({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      _rides = [];
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _api.getAdminRides(
        page: _currentPage,
        limit: _pageSize,
        status: _statusFilter,
      );
      _rides = result;
      // Backend should return total count; mock here
      _totalCount = result.length < _pageSize
          ? (_currentPage - 1) * _pageSize + result.length
          : _currentPage * _pageSize + 1;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load rides.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    loadRides(reset: true);
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    loadRides(reset: true);
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
    loadRides(reset: true);
  }

  void setPaymentMethodFilter(String? method) {
    _paymentMethodFilter = method;
    loadRides(reset: true);
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPages) return;
    _currentPage = page;
    loadRides();
  }
}
