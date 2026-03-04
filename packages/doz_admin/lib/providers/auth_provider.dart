import 'package:flutter/foundation.dart';
import 'package:doz_shared/doz_shared.dart';
import 'package:dio/dio.dart';

/// Authentication provider for admin panel.
/// Handles email+password login (admin-specific endpoint).
class AuthProvider extends ChangeNotifier {
  final ApiClient _api;
  final StorageService _storage;
  final Dio _dio;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  AuthProvider({required ApiClient api, required StorageService storage})
      : _api = api,
        _storage = storage,
        _dio = Dio(BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ));

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get initialized => _initialized;

  /// Admin email+password login.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _dio.post('/admin/login', data: {
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String? ?? '';
      final userJson = data['user'] as Map<String, dynamic>?;

      if (userJson == null) {
        _error = 'Invalid response from server';
        _setLoading(false);
        return false;
      }

      final user = UserModel.fromJson(userJson);
      if (user.role != UserRole.admin) {
        _error = 'Access denied. Admin accounts only.';
        _setLoading(false);
        return false;
      }

      await _storage.saveTokens(
          accessToken: accessToken, refreshToken: refreshToken);
      await _storage.saveUserId(user.id);

      _currentUser = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Login failed. Please check your credentials.';
      if (data is Map<String, dynamic>) {
        message = data['message'] as String? ?? message;
      }
      _error = message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Login failed. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  /// Try to auto-login from stored token.
  Future<void> tryAutoLogin() async {
    _initialized = false;
    notifyListeners();
    try {
      final token = await _storage.getAccessToken();
      if (token != null) {
        final user = await _api.getProfile();
        if (user.role == UserRole.admin) {
          _currentUser = user;
        } else {
          await _storage.clearTokens();
        }
      }
    } catch (_) {
      await _storage.clearTokens();
      _currentUser = null;
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  /// Logout and clear stored tokens.
  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}
    await _storage.clearTokens();
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
