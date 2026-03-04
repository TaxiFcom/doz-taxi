import 'package:flutter/foundation.dart';
import 'package:doz_shared/doz_shared.dart';

/// Dashboard statistics model.
class DashboardStats {
  final int totalRides;
  final int todayRides;
  final int activeRides;
  final int totalRiders;
  final int totalDrivers;
  final int onlineDrivers;
  final double totalRevenue;
  final double todayRevenue;
  final List<RevenueDataPoint> revenueChart;
  final List<RidesDataPoint> ridesChart;
  final List<RideModel> recentRides;

  const DashboardStats({
    this.totalRides = 0,
    this.todayRides = 0,
    this.activeRides = 0,
    this.totalRiders = 0,
    this.totalDrivers = 0,
    this.onlineDrivers = 0,
    this.totalRevenue = 0,
    this.todayRevenue = 0,
    this.revenueChart = const [],
    this.ridesChart = const [],
    this.recentRides = const [],
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final revenueList = (json['revenueChart'] as List<dynamic>? ?? [])
        .map((e) => RevenueDataPoint.fromJson(e as Map<String, dynamic>))
        .toList();
    final ridesList = (json['ridesChart'] as List<dynamic>? ?? [])
        .map((e) => RidesDataPoint.fromJson(e as Map<String, dynamic>))
        .toList();
    final recentList = (json['recentRides'] as List<dynamic>? ?? [])
        .map((e) => RideModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return DashboardStats(
      totalRides: json['totalRides'] as int? ?? 0,
      todayRides: json['todayRides'] as int? ?? 0,
      activeRides: json['activeRides'] as int? ?? 0,
      totalRiders: json['totalRiders'] as int? ?? 0,
      totalDrivers: json['totalDrivers'] as int? ?? 0,
      onlineDrivers: json['onlineDrivers'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0,
      revenueChart: revenueList,
      ridesChart: ridesList,
      recentRides: recentList,
    );
  }
}

class RevenueDataPoint {
  final DateTime date;
  final double amount;
  RevenueDataPoint({required this.date, required this.amount});
  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) =>
      RevenueDataPoint(
        date: DateTime.parse(json['date'] as String),
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
      );
}

class RidesDataPoint {
  final DateTime date;
  final int count;
  RidesDataPoint({required this.date, required this.count});
  factory RidesDataPoint.fromJson(Map<String, dynamic> json) => RidesDataPoint(
        date: DateTime.parse(json['date'] as String),
        count: json['count'] as int? ?? 0,
      );
}

class DashboardProvider extends ChangeNotifier {
  final ApiClient _api;

  DashboardStats _stats = const DashboardStats();
  bool _isLoading = false;
  String? _error;

  DashboardProvider({required ApiClient api}) : _api = api;

  DashboardStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.getAdminDashboardStats();
      _stats = DashboardStats.fromJson(data);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load dashboard data.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
