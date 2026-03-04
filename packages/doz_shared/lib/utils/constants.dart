/// Application-wide constants for DOZ Taxi.
abstract class AppConstants {
  static const String baseUrl = 'https://api.doz.taxi/api/v1';
  static const String devBaseUrl = 'http://localhost:3000/api/v1';
  static const String wsUrl = 'wss://api.doz.taxi';
  static const String devWsUrl = 'ws://localhost:3000';

  static const double defaultLat = 31.9539;
  static const double defaultLng = 35.9106;
  static const double defaultZoom = 14.0;
  static const double driverMarkersZoom = 12.0;
  static const double streetZoom = 16.0;

  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration bidTimeout = Duration(minutes: 2);
  static const Duration rideRequestTimeout = Duration(minutes: 5);
  static const Duration locationUpdateInterval = Duration(seconds: 5);
  static const Duration otpResendCooldown = Duration(seconds: 60);

  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 350);

  static const double commissionRate = 0.15;
  static const double minRidePrice = 1.5;
  static const double maxRidePrice = 500.0;
  static const double minTopUpAmount = 5.0;
  static const double maxTopUpAmount = 500.0;
  static const double driverSearchRadius = 10.0;
  static const int maxBidsPerRide = 10;

  static const int defaultPageSize = 20;
  static const int notificationsPageSize = 30;
  static const int historyPageSize = 20;

  static const List<String> supportedLocales = ['ar', 'en'];
  static const String defaultLocale = 'ar';

  static const String fcmTokenKey = 'fcm_token';
  static const String deviceIdKey = 'device_id';
  static const String appVersionKey = 'app_version';

  static const String supportPhone = '+962XXXXXXXXX';
  static const String supportEmail = 'support@doz.taxi';
  static const String termsUrl = 'https://doz.taxi/terms';
  static const String privacyUrl = 'https://doz.taxi/privacy';

  static const String jordanCountryCode = '+962';
  static const String defaultCurrency = 'JOD';
}
