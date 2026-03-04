import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _api;
  final StorageService? _storage;

  AuthProvider(this._api, {StorageService? storage, String initialLocale = 'ar'})
      : _storage = storage {
    _locale = Locale(initialLocale);
  }

  UserModel? _user;
  bool _loading = false;
  String? _error;
  late Locale _locale;

  UserModel? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  Locale get locale => _locale;

  void setLocale(String langCode) {
    _locale = Locale(langCode);
    _storage?.setLanguage(langCode);
    notifyListeners();
  }

  Future<bool> sendOtp(String phone, String countryCode) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.requestOtp(phone: phone, countryCode: countryCode);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String countryCode, String code) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.verifyOtp(
        phone: phone,
        countryCode: countryCode,
        otp: code,
        role: 'rider',
      );
      if (res['token'] != null || res['accessToken'] != null) {
        final token = (res['accessToken'] ?? res['token']) as String;
        await _storage?.saveTokens(accessToken: token, refreshToken: res['refreshToken'] as String? ?? '');
        if (res['user'] != null) {
          _user = UserModel.fromJson(res['user'] as Map<String, dynamic>);
        }
      }
      return res;
    } catch (e) {
      _error = e.toString();
      return {'error': e.toString()};
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, {String? email}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api.registerUser(
        name: name,
        phone: _user?.phone ?? '',
        role: 'rider',
        email: email,
      );
      if (res['user'] != null) {
        _user = UserModel.fromJson(res['user'] as Map<String, dynamic>);
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

  Future<bool> tryAutoLogin() async {
    try {
      final token = await _storage?.getAccessToken();
      if (token == null) return false;
      _user = await _api.getProfile();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadProfile() async {
    try {
      _user = await _api.getProfile();
      notifyListeners();
    } catch (_) {}
  }

  Future<UserModel?> updateProfile({String? name, String? email}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _api.updateProfile(name: name, email: email);
      return _user;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadAvatar(String filePath) async {
    try {
      final url = await _api.uploadAvatar(filePath);
      await loadProfile();
      return url;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    await _storage?.clearTokens();
    _user = null;
    notifyListeners();
  }
}
