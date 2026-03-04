import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../models/driver_model.dart';
import '../models/enums.dart';
import 'api_client.dart';
import 'storage_service.dart';

/// Result of an auth operation.
class AuthResult {
  final bool isNewUser;
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  const AuthResult({
    required this.isNewUser,
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}

/// Service managing authentication state and flow.
/// OTP-based login/register, token persistence, auto-login.
class AuthService {
  static AuthService? _instance;
  final ApiClient _api;
  final StorageService _storage;
  final Logger _logger = Logger();

  UserModel? _currentUser;
  DriverModel? _currentDriver;

  AuthService._(this._api, this._storage);

  static AuthService getInstance(ApiClient api, StorageService storage) {
    _instance ??= AuthService._(api, storage);
    return _instance!;
  }

  UserModel? get currentUser => _currentUser;
  DriverModel? get currentDriver => _currentDriver;
  bool get isLoggedIn => _currentUser != null;

  Future<String?> requestOtp({
    required String phone,
    required String countryCode,
  }) async {
    try {
      final result = await _api.requestOtp(
        phone: phone,
        countryCode: countryCode,
      );
      _logger.i('[Auth] OTP requested for $countryCode$phone');
      return result['requestId'] as String?;
    } catch (e) {
      _logger.e('[Auth] OTP request failed: $e');
      rethrow;
    }
  }

  Future<AuthResult> verifyOtp({
    required String phone,
    required String countryCode,
    required String otp,
    required UserRole role,
  }) async {
    try {
      final result = await _api.verifyOtp(
        phone: phone,
        countryCode: countryCode,
        otp: otp,
        role: role.toJson(),
      );

      final accessToken = result['accessToken'] as String;
      final refreshToken = result['refreshToken'] as String;
      final isNewUser = result['isNewUser'] as bool? ?? false;

      await _storage.saveTokens(
          accessToken: accessToken, refreshToken: refreshToken);

      UserModel? user;
      if (!isNewUser && result['user'] != null) {
        user = UserModel.fromJson(
            result['user'] as Map<String, dynamic>);
        _currentUser = user;
        await _storage.saveUserId(user.id);
      }

      _logger.i('[Auth] OTP verified, isNewUser: $isNewUser');

      return AuthResult(
        isNewUser: isNewUser,
        user: user ??
            UserModel(
              id: '',
              name: '',
              phone: '$countryCode$phone',
              role: role,
              createdAt: DateTime.now(),
            ),
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (e) {
      _logger.e('[Auth] OTP verify failed: $e');
      rethrow;
    }
  }

  Future<AuthResult> register({
    required String name,
    required String phone,
    required String countryCode,
    required UserRole role,
    String lang = 'ar',
    String? email,
  }) async {
    try {
      final result = await _api.registerUser(
        name: name,
        phone: '$countryCode$phone',
        role: role.toJson(),
        lang: lang,
        email: email,
      );

      final accessToken = result['accessToken'] as String;
      final refreshToken = result['refreshToken'] as String;
      final user = UserModel.fromJson(
          result['user'] as Map<String, dynamic>);

      await _storage.saveTokens(
          accessToken: accessToken, refreshToken: refreshToken);
      await _storage.saveUserId(user.id);
      await _storage.saveLanguage(lang);

      _currentUser = user;
      _logger.i('[Auth] Registered user: ${user.id}');

      return AuthResult(
        isNewUser: true,
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (e) {
      _logger.e('[Auth] Registration failed: $e');
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null) return false;

      final user = await _api.getProfile();
      _currentUser = user;

      if (user.role == UserRole.driver) {
        try {
          _currentDriver = await _api.getDriverProfile();
        } catch (_) {}
      }

      _logger.i('[Auth] Auto-login success for ${user.id}');
      return true;
    } catch (e) {
      _logger.w('[Auth] Auto-login failed: $e');
      await _storage.clearTokens();
      return false;
    }
  }

  Future<UserModel> refreshProfile() async {
    final user = await _api.getProfile();
    _currentUser = user;
    return user;
  }

  Future<DriverModel> refreshDriverProfile() async {
    final driver = await _api.getDriverProfile();
    _currentDriver = driver;
    return driver;
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}
    await _storage.clearTokens();
    await _storage.clearUserId();
    _currentUser = null;
    _currentDriver = null;
    _logger.i('[Auth] Logged out');
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? lang,
  }) async {
    final updated = await _api.updateProfile(
        name: name, email: email, lang: lang);
    _currentUser = updated;
    if (lang != null) await _storage.saveLanguage(lang);
    return updated;
  }

  Future<String> uploadAvatar(String filePath) async {
    final url = await _api.uploadAvatar(filePath);
    _currentUser = _currentUser?.copyWith(avatarUrl: url);
    return url;
  }
}
