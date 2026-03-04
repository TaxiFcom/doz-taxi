import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// Keys used for secure storage and shared preferences.
class _Keys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String language = 'language';
  static const String darkMode = 'dark_mode';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String onboardingComplete = 'onboarding_complete';
  static const String lastKnownLat = 'last_known_lat';
  static const String lastKnownLng = 'last_known_lng';
}

/// Persistent storage service.
/// - Secure storage for tokens (uses Keychain/Keystore)
/// - SharedPreferences for settings and preferences
class StorageService {
  static StorageService? _instance;
  final Logger _logger = Logger();

  late final FlutterSecureStorage _secureStorage;
  late SharedPreferences _prefs;
  bool _initialized = false;

  StorageService._();

  static StorageService getInstance() {
    _instance ??= StorageService._();
    return _instance!;
  }

  Future<void> init() async {
    if (_initialized) return;

    const androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,
    );
    const iosOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    );

    _secureStorage = const FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
    );

    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
    _logger.i('[Storage] Initialized');
  }

  void _checkInit() {
    if (!_initialized) {
      throw StateError(
          'StorageService not initialized. Call init() first.');
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _checkInit();
    await Future.wait([
      _secureStorage.write(
          key: _Keys.accessToken, value: accessToken),
      _secureStorage.write(
          key: _Keys.refreshToken, value: refreshToken),
    ]);
    _logger.d('[Storage] Tokens saved');
  }

  Future<String?> getAccessToken() async {
    _checkInit();
    return _secureStorage.read(key: _Keys.accessToken);
  }

  Future<String?> getRefreshToken() async {
    _checkInit();
    return _secureStorage.read(key: _Keys.refreshToken);
  }

  Future<void> clearTokens() async {
    _checkInit();
    await Future.wait([
      _secureStorage.delete(key: _Keys.accessToken),
      _secureStorage.delete(key: _Keys.refreshToken),
    ]);
    _logger.d('[Storage] Tokens cleared');
  }

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveUserId(String userId) async {
    _checkInit();
    await _secureStorage.write(key: _Keys.userId, value: userId);
  }

  Future<String?> getUserId() async {
    _checkInit();
    return _secureStorage.read(key: _Keys.userId);
  }

  Future<void> clearUserId() async {
    _checkInit();
    await _secureStorage.delete(key: _Keys.userId);
  }

  Future<void> saveLanguage(String lang) async {
    _checkInit();
    await _prefs.setString(_Keys.language, lang);
  }

  Future<String> getLanguage() async {
    _checkInit();
    return _prefs.getString(_Keys.language) ?? 'ar';
  }

  Future<void> saveDarkMode(bool isDark) async {
    _checkInit();
    await _prefs.setBool(_Keys.darkMode, isDark);
  }

  bool getDarkMode() {
    _checkInit();
    return _prefs.getBool(_Keys.darkMode) ?? true;
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    _checkInit();
    await _prefs.setBool(_Keys.notificationsEnabled, enabled);
  }

  bool getNotificationsEnabled() {
    _checkInit();
    return _prefs.getBool(_Keys.notificationsEnabled) ?? true;
  }

  Future<void> setOnboardingComplete() async {
    _checkInit();
    await _prefs.setBool(_Keys.onboardingComplete, true);
  }

  bool isOnboardingComplete() {
    _checkInit();
    return _prefs.getBool(_Keys.onboardingComplete) ?? false;
  }

  Future<void> saveLastKnownLocation(double lat, double lng) async {
    _checkInit();
    await Future.wait([
      _prefs.setDouble(_Keys.lastKnownLat, lat),
      _prefs.setDouble(_Keys.lastKnownLng, lng),
    ]);
  }

  ({double? lat, double? lng}) getLastKnownLocation() {
    _checkInit();
    final lat = _prefs.getDouble(_Keys.lastKnownLat);
    final lng = _prefs.getDouble(_Keys.lastKnownLng);
    return (lat: lat, lng: lng);
  }

  Future<void> setString(String key, String value) async {
    _checkInit();
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    _checkInit();
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    _checkInit();
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    _checkInit();
    return _prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    _checkInit();
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    _checkInit();
    return _prefs.getInt(key);
  }

  Future<void> clearAll() async {
    _checkInit();
    await _prefs.clear();
    await _secureStorage.deleteAll();
    _logger.i('[Storage] All data cleared');
  }
}
