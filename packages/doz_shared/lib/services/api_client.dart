import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/bid_model.dart';
import '../models/driver_model.dart';
import '../models/notification_model.dart';
import '../models/rating_model.dart';
import '../models/ride_model.dart';
import '../models/user_model.dart';
import '../models/vehicle_type_model.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

/// Custom exception for API errors.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? errorCode;

  const ApiException({
    this.statusCode,
    required this.message,
    this.errorCode,
  });

  @override
  String toString() =>
      'ApiException(status: $statusCode, message: $message, code: $errorCode)';
}

/// Centralized HTTP client for all DOZ API calls.
/// Uses Dio with JWT auth, auto-refresh on 401, and error handling.
class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final StorageService _storage;
  final Logger _logger = Logger();
  bool _isRefreshing = false;

  ApiClient._(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  static ApiClient getInstance(StorageService storage) {
    _instance ??= ApiClient._(storage);
    return _instance!;
  }

  // ── Interceptors ──────────────────────────────────────────────────────────────────────

  Future<void> _onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    final lang = await _storage.getLanguage();
    options.headers['Accept-Language'] = lang;
    _logger.d('[API] ${options.method} ${options.path}');
    handler.next(options);
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('[API] ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  Future<void> _onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          final token = await _storage.getAccessToken();
          final opts = err.requestOptions
            ..headers['Authorization'] = 'Bearer $token';
          final clonedReq = await _dio.fetch(opts);
          handler.resolve(clonedReq);
          return;
        }
      } catch (_) {
        await _storage.clearTokens();
      } finally {
        _isRefreshing = false;
      }
    }
    _logger.e('[API ERROR] ${err.message}');
    handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return false;

    final response = await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      options: Options(headers: {}),
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      await _storage.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String? ?? refreshToken,
      );
      return true;
    }
    return false;
  }

  // ── Helper ─────────────────────────────────────────────────────────────────────────

  T _parseResponse<T>(Response response, T Function(dynamic) parser) {
    try {
      return parser(response.data);
    } catch (e) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Failed to parse response: $e',
      );
    }
  }

  ApiException _handleError(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      String message = 'An error occurred';
      String? errorCode;
      if (data is Map<String, dynamic>) {
        message = data['message'] as String? ?? message;
        errorCode = data['code'] as String?;
      }
      return ApiException(
        statusCode: e.response?.statusCode,
        message: message,
        errorCode: errorCode,
      );
    }
    return ApiException(message: e.toString());
  }

  // ── Auth Endpoints ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> requestOtp({
    required String phone,
    required String countryCode,
  }) async {
    try {
      final response = await _dio.post('/auth/otp/request', data: {
        'phone': phone,
        'countryCode': countryCode,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String countryCode,
    required String otp,
    required String role,
  }) async {
    try {
      final response = await _dio.post('/auth/otp/verify', data: {
        'phone': phone,
        'countryCode': countryCode,
        'otp': otp,
        'role': role,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String phone,
    required String role,
    String lang = 'ar',
    String? email,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'phone': phone,
        'role': role,
        'lang': lang,
        if (email != null) 'email': email,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (_) {
      // Ignore errors on logout
    }
  }

  // ── User Endpoints ────────────────────────────────────────────────────────────────

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get('/users/me');
      return _parseResponse(
          response, (d) => UserModel.fromJson(d as Map<String, dynamic>));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? lang,
  }) async {
    try {
      final response = await _dio.put('/users/me', data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (lang != null) 'lang': lang,
      });
      return _parseResponse(
          response, (d) => UserModel.fromJson(d as Map<String, dynamic>));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });
      final response =
          await _dio.post('/users/me/avatar', data: formData);
      return (response.data as Map<String, dynamic>)['avatarUrl'] as String;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Ride Endpoints ────────────────────────────────────────────────────────────────

  Future<RideModel> createRide({
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffAddress,
    required double suggestedPrice,
    required String paymentMethod,
    String? vehicleType,
  }) async {
    try {
      final response = await _dio.post('/rides', data: {
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'pickupAddress': pickupAddress,
        'dropoffLat': dropoffLat,
        'dropoffLng': dropoffLng,
        'dropoffAddress': dropoffAddress,
        'suggestedPrice': suggestedPrice,
        'paymentMethod': paymentMethod,
        if (vehicleType != null) 'vehicleType': vehicleType,
      });
      return _parseResponse(
          response, (d) => RideModel.fromJson(d as Map<String, dynamic>));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RideModel> getRide(String rideId) async {
    try {
      final response = await _dio.get('/rides/$rideId');
      return _parseResponse(
          response, (d) => RideModel.fromJson(d as Map<String, dynamic>));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<RideModel>> getRideHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/rides/history', queryParameters: {
        'page': page,
        'limit': limit,
      });
      final data =
          (response.data as Map<String, dynamic>)['rides'] as List<dynamic>;
      return data
          .map((e) => RideModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RideModel> cancelRide(String rideId, {String? reason}) async {
    try {
      final response = await _dio.post('/rides/$rideId/cancel', data: {
        if (reason != null) 'reason': reason,
      });
      return _parseResponse(
          response, (d) => RideModel.fromJson(d as Map<String, dynamic>));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RideModel> updateRideStatus(
      String rideId, String status) async {
    try {
      final response = await _dio
          .post('/rides/$rideId/status', data: {'status': status});
      return _parseResponse(
          response, (d) => RideModel.fromJson(d as Map<String, dynamic>));
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Bid Endpoints ──────────────────────────────────────────────────────────────────

  Future<BidModel> placeBid({
    required String rideId,
    required double amount,
  }) async {
    try {
      final response = await _dio.post('/bids', data: {
        'rideId': rideId,
        'amount': amount,
      });
      return _parseResponse(
          response, (d) => BidModel.fromJson(d as Map<String, dynamic>));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<BidModel>> getRideBids(String rideId) async {
    try {
      final response = await _dio.get('/bids/ride/$rideId');
      final data = response.data as List<dynamic>;
      return data
          .map((e) => BidModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RideModel> acceptBid(String bidId) async {
    try {
      final response = await _dio.post('/bids/$bidId/accept');
      return _parseResponse(
          response, (d) => RideModel.fromJson(d as Map<String, dynamic>));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> rejectBid(String bidId) async {
    try {
      await _dio.post('/bids/$bidId/reject');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Rating Endpoints ───────────────────────────────────────────────────────────────

  Future<RatingModel> submitRating({
    required String rideId,
    required String toUserId,
    required int stars,
    List<String> tags = const [],
    String? comment,
  }) async {
    try {
      final response = await _dio.post('/ratings', data: {
        'rideId': rideId,
        'toUserId': toUserId,
        'stars': stars,
        'tags': tags,
        if (comment != null) 'comment': comment,
      });
      return _parseResponse(
          response, (d) => RatingModel.fromJson(d as Map<String, dynamic>));
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Driver Endpoints ───────────────────────────────────────────────────────────────

  Future<DriverModel> getDriverProfile() async {
    try {
      final response = await _dio.get('/drivers/me');
      return _parseResponse(
          response,
          (d) => DriverModel.fromJson(d as Map<String, dynamic>));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<DriverModel> toggleOnlineStatus(bool isOnline) async {
    try {
      final response = await _dio.post('/drivers/me/status', data: {
        'isOnline': isOnline,
      });
      return _parseResponse(
          response,
          (d) => DriverModel.fromJson(d as Map<String, dynamic>));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getDriverEarnings({
    required String period, // 'today', 'week', 'month'
  }) async {
    try {
      final response = await _dio.get('/drivers/me/earnings',
          queryParameters: {'period': period});
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Wallet Endpoints ───────────────────────────────────────────────────────────────

  Future<WalletModel> getWallet() async {
    try {
      final response = await _dio.get('/wallet');
      return _parseResponse(
          response, (d) => WalletModel.fromJson(d as Map<String, dynamic>));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<WalletTransactionModel>> getWalletTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/wallet/transactions',
          queryParameters: {'page': page, 'limit': limit});
      final data = response.data as List<dynamic>;
      return data
          .map((e) => WalletTransactionModel.fromJson(
              e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<WalletModel> topUpWallet({
    required double amount,
    required String paymentMethod,
    String? cardToken,
  }) async {
    try {
      final response = await _dio.post('/wallet/topup', data: {
        'amount': amount,
        'paymentMethod': paymentMethod,
        if (cardToken != null) 'cardToken': cardToken,
      });
      return _parseResponse(
          response, (d) => WalletModel.fromJson(d as Map<String, dynamic>));
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Notifications ─────────────────────────────────────────────────────────────────

  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/notifications',
          queryParameters: {'page': page, 'limit': limit});
      final data = response.data as List<dynamic>;
      return data
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markNotificationRead(String notificationId) async {
    try {
      await _dio.post('/notifications/$notificationId/read');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _dio.post('/notifications/read-all');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> registerFcmToken(String token, String platform) async {
    try {
      await _dio.post('/notifications/register-token', data: {
        'token': token,
        'platform': platform,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Vehicle Types ─────────────────────────────────────────────────────────────────

  Future<List<VehicleTypeModel>> getVehicleTypes() async {
    try {
      final response = await _dio.get('/vehicle-types');
      final data = response.data as List<dynamic>;
      return data
          .map((e) => VehicleTypeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ── Admin Endpoints ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAdminDashboardStats() async {
    try {
      final response = await _dio.get('/admin/dashboard');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<UserModel>> getAdminUsers({
    required String role,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final response = await _dio.get('/admin/users', queryParameters: {
        'role': role,
        'page': page,
        'limit': limit,
        if (search != null) 'search': search,
      });
      final data =
          (response.data as Map<String, dynamic>)['users'] as List<dynamic>;
      return data
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> adminBlockUser(
      String userId, bool isBlocked) async {
    try {
      final response =
          await _dio.post('/admin/users/$userId/block', data: {
        'isBlocked': isBlocked,
      });
      return _parseResponse(
          response, (d) => UserModel.fromJson(d as Map<String, dynamic>));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<DriverModel> adminApproveDriver(String driverId) async {
    try {
      final response =
          await _dio.post('/admin/drivers/$driverId/approve');
      return _parseResponse(
          response,
          (d) => DriverModel.fromJson(d as Map<String, dynamic>));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<RideModel>> getAdminRides({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final response = await _dio.get('/admin/rides', queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      });
      final data =
          (response.data as Map<String, dynamic>)['rides'] as List<dynamic>;
      return data
          .map((e) => RideModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }
}
