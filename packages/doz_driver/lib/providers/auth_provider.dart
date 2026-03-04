import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  needsRegistration,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storage;

  AuthState _state = AuthState.initial;
  UserModel? _user;
  DriverModel? _driver;
  String? _errorMessage;
  String? _phone;
  String? _countryCode;
  String _lang = AppConstants.defaultLocale;

  AuthProvider({
    required AuthService authService,
    required StorageService storage,
  })  : _authService = authService,
        _storage = storage;

  AuthState get state => _state;
  UserModel? get user => _user;
  DriverModel? get driver => _driver;
  String? get errorMessage => _errorMessage;
  String get phone => _phone ?? '';
  String get countryCode => _countryCode ?? AppConstants.jordanCountryCode;
  String get lang => _lang;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  Future<void> init() async {
    _state = AuthState.loading;
    notifyListeners();
    try {
      _lang = await _storage.getLanguage() ?? AppConstants.defaultLocale;
      final loggedIn = await _authService.tryAutoLogin();
      if (loggedIn) {
        _user = _authService.currentUser;
        _driver = _authService.currentDriver;
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> requestOtp({
    required String phone,
    required String countryCode,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.requestOtp(phone: phone, countryCode: countryCode);
      _phone = phone;
      _countryCode = countryCode;
      _state = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _authService.verifyOtp(
        phone: _phone!,
        countryCode: _countryCode!,
        otp: otp,
        role: UserRole.driver,
      );
      if (result.isNewUser) {
        _state = AuthState.needsRegistration;
        notifyListeners();
        return false;
      } else {
        _user = result.user;
        _driver = _authService.currentDriver;
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    String? email,
    required String vehicleType,
    required String vehicleModel,
    required String vehicleColor,
    required String plateNumber,
    required String licenseNumber,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _authService.register(
        name: name,
        phone: _phone!,
        countryCode: _countryCode!,
        role: UserRole.driver,
        lang: _lang,
        email: email,
      );
      _user = result.user;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> setLanguage(String lang) async {
    _lang = lang;
    await _storage.saveLanguage(lang);
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      _user = await _authService.refreshProfile();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> updateProfile({String? name, String? email}) async {
    try {
      _user = await _authService.updateProfile(name: name, email: email);
      notifyListeners();
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _driver = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
