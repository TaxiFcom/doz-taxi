import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Manages wallet balance and transactions for the rider.
class WalletProvider extends ChangeNotifier {
  final ApiClient _api;

  WalletProvider(this._api);

  double _balance = 0.0;
  List<TransactionModel> _transactions = [];
  bool _loading = false;
  String? _error;

  double get balance => _balance;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> loadWallet() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.get('/wallet');
      _balance = (res['balance'] as num).toDouble();
      _transactions = (res['transactions'] as List)
          .map((t) => TransactionModel.fromJson(t))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> topUp(double amount, String method) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.post('/wallet/topup', {
        'amount': amount,
        'method': method,
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
