import 'package:flutter/foundation.dart';
import 'package:doz_shared/doz_shared.dart';

class PaymentSummary {
  final double totalAmount;
  final double totalCommission;
  final double totalTopUps;
  final double totalRefunds;
  final int transactionCount;

  const PaymentSummary({
    this.totalAmount = 0,
    this.totalCommission = 0,
    this.totalTopUps = 0,
    this.totalRefunds = 0,
    this.transactionCount = 0,
  });
}

class PaymentTransaction {
  final String id;
  final String userId;
  final String userName;
  final WalletTransactionType type;
  final double amount;
  final PaymentMethod method;
  final DateTime createdAt;
  final String description;

  const PaymentTransaction({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.amount,
    required this.method,
    required this.createdAt,
    required this.description,
  });
}

class RevenueByVehicleType {
  final String vehicleType;
  final double revenue;
  final int rides;

  const RevenueByVehicleType({
    required this.vehicleType,
    required this.revenue,
    required this.rides,
  });
}

class TopDriver {
  final String driverId;
  final String driverName;
  final double earnings;
  final int rides;
  final double rating;

  const TopDriver({
    required this.driverId,
    required this.driverName,
    required this.earnings,
    required this.rides,
    required this.rating,
  });
}

class PaymentsProvider extends ChangeNotifier {
  final ApiClient _api;

  List<WalletTransactionModel> _transactions = [];
  PaymentSummary _summary = const PaymentSummary();
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  int _total = 0;
  static const int _pageSize = 20;

  WalletTransactionType? _typeFilter;
  DateTime? _fromDate;
  DateTime? _toDate;

  PaymentsProvider({required ApiClient api}) : _api = api;

  List<WalletTransactionModel> get transactions => _transactions;
  PaymentSummary get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get page => _page;
  int get total => _total;
  int get totalPages => (_total / _pageSize).ceil().clamp(1, 9999);
  WalletTransactionType? get typeFilter => _typeFilter;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  Future<void> loadTransactions({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _transactions = [];
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _api.getWalletTransactions(
        page: _page,
        limit: _pageSize,
      );
      _transactions = result;
      _total = result.length < _pageSize
          ? (_page - 1) * _pageSize + result.length
          : _page * _pageSize + 1;
      _computeSummary();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load transactions.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _computeSummary() {
    double total = 0, commission = 0, topUps = 0, refunds = 0;
    for (final t in _transactions) {
      switch (t.type) {
        case WalletTransactionType.payment:
          total += t.amount;
          break;
        case WalletTransactionType.commission:
          commission += t.amount;
          break;
        case WalletTransactionType.topUp:
          topUps += t.amount;
          break;
        case WalletTransactionType.refund:
          refunds += t.amount;
          break;
        default:
          break;
      }
    }
    _summary = PaymentSummary(
      totalAmount: total,
      totalCommission: commission,
      totalTopUps: topUps,
      totalRefunds: refunds,
      transactionCount: _transactions.length,
    );
  }

  void setTypeFilter(WalletTransactionType? type) {
    _typeFilter = type;
    loadTransactions(reset: true);
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
    loadTransactions(reset: true);
  }

  void goToPage(int page) {
    if (page < 1) return;
    _page = page;
    loadTransactions();
  }
}
