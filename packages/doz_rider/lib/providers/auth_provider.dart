import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Auth state provider for the rider app.
class AuthProvider extends ChangeNotifier {
  final ApiClient _api;

  AuthProvider(this._api);

  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> sendOtp(String phone, String countryCode) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.post('/auth/send-otp', {
        'phone': phone,
        'countryCode': countryCode,
      });
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(
      String phone, String countryCode, String code) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.post('/auth/verify-otp', {
        'phone': phone,
        'countryCode': countryCode,
        'code': code,
      });
      if (res['token'] != null) {
        await _api.setToken(res['token']);
        if (res['user'] != null) {
          _user = UserModel.fromJson(res['user']);
        }
        return true;
      }
      _error = 'Invalid OTP';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.post('/auth/register', {
        'name': name,
        'email': email,
      });
      if (res['user'] != null) {
        _user = UserModel.fromJson(res['user']);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    try {
      final res = await _api.get('/users/me');
      _user = UserModel.fromJson(res);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> logout() async {
    await _api.clearToken();
    _user = null;
    notifyListeners();
  }
}
