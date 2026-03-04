import 'package:flutter/foundation.dart';
import 'package:doz_shared/doz_shared.dart';

class AdminSettings {
  final double commissionRate;
  final String defaultLanguage;
  final bool notificationsEnabled;
  final String appVersion;

  const AdminSettings({
    this.commissionRate = 0.15,
    this.defaultLanguage = 'ar',
    this.notificationsEnabled = true,
    this.appVersion = '1.0.0',
  });

  AdminSettings copyWith({
    double? commissionRate,
    String? defaultLanguage,
    bool? notificationsEnabled,
    String? appVersion,
  }) {
    return AdminSettings(
      commissionRate: commissionRate ?? this.commissionRate,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;

  AdminSettings _settings = const AdminSettings();
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _successMessage;

  SettingsProvider({required StorageService storage}) : _storage = storage;

  AdminSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  String? get successMessage => _successMessage;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    // Load from local storage or API
    await Future.delayed(const Duration(milliseconds: 200));
    _settings = const AdminSettings();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveSettings(AdminSettings newSettings) async {
    _isSaving = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _settings = newSettings;
      _successMessage = 'Settings saved successfully.';
    } catch (e) {
      _error = 'Failed to save settings.';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
