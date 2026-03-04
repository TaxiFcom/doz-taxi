import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Manages wallet balance and transactions for the rider.
class WalletProvider extends ChangeNotifier {
  final ApiClient _api;

  WalletProvider(this._api);

  double _balance = 0.0;
  String _currency = 'JOD';
  List<WalletTransactionModel> _transactions = [];
  bool _loading = false;
  bool _transactionsLoading = false;
  String? _error;

  // ===================== GETTERS =====================

  double get balance => _balance;
  String get currency => _currency;
  List<WalletTransactionModel> get transactions => _transactions;
  bool get isLoading => _loading;
  bool get loading => _loading;
  bool get transactionsLoading => _transactionsLoading;
  String? get error => _error;

  // ===================== LOAD WALLET =====================

  /// Load wallet balance.
  Future<void> loadWallet() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.get('/wallet');
      _balance = (res['balance'] as num).toDouble();
      if (res['currency'] != null) {
        _currency = res['currency'] as String;
      }
      // If transactions come with wallet response, load them too.
      if (res['transactions'] is List) {
        _transactions = (res['transactions'] as List)
            .map((t) => WalletTransactionModel.fromJson(t))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ===================== LOAD TRANSACTIONS =====================

  /// Load transaction history separately.
  Future<void> loadTransactions({bool refresh = false}) async {
    _transactionsLoading = true;
    if (refresh) {
      _transactions = [];
    }
    notifyListeners();
    try {
      final res = await _api.get('/wallet/transactions');
      if (res is List) {
        _transactions =
            res.map((t) => WalletTransactionModel.fromJson(t)).toList();
      } else if (res is Map && res['transactions'] is List) {
        _transactions = (res['transactions'] as List)
            .map((t) => WalletTransactionModel.fromJson(t))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _transactionsLoading = false;
      notifyListeners();
    }
  }

  // ===================== TOP UP =====================

  /// Top up wallet with named parameters (matching screen usage).
  Future<bool> topUp({
    required double amount,
    required String paymentMethod,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.post('/wallet/topup', {
        'amount': amount,
        'method': paymentMethod,
      });
      _balance = (res['balance'] as num).toDouble();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
