import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

enum EarningsPeriod { today, week, month }

class DailyEarning {
  final DateTime date;
  final double amount;
  final int rides;

  const DailyEarning({
    required this.date,
    required this.amount,
    required this.rides,
  });
}

class EarningsSummary {
  final double totalEarnings;
  final double commissionPaid;
  final double netEarnings;
  final int totalRides;
  final double averagePerRide;
  final double onlineHours;
  final List<DailyEarning> dailyBreakdown;
  final List<RideModel> recentRides;

  const EarningsSummary({
    required this.totalEarnings,
    required this.commissionPaid,
    required this.netEarnings,
    required this.totalRides,
    required this.averagePerRide,
    required this.onlineHours,
    required this.dailyBreakdown,
    required this.recentRides,
  });
}

/// Earnings provider — fetches and stores driver earnings data.
class EarningsProvider extends ChangeNotifier {
  final ApiClient _api;

  EarningsPeriod _period = EarningsPeriod.today;
  EarningsSummary? _summary;
  double _todayEarnings = 0;
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  EarningsProvider({required ApiClient api}) : _api = api;

  EarningsPeriod get period => _period;
  EarningsSummary? get summary => _summary;
  double get todayEarnings => _todayEarnings;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  Future<void> loadEarnings([EarningsPeriod? period]) async {
    if (period != null) _period = period;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final periodKey = _period == EarningsPeriod.today
          ? 'today'
          : _period == EarningsPeriod.week
              ? 'week'
              : 'month';

      final data = await _api.getDriverEarnings(period: periodKey);

      final totalEarnings = (data['totalEarnings'] as num?)?.toDouble() ?? 0.0;
      final commissionPaid = (data['commissionPaid'] as num?)?.toDouble() ??
          totalEarnings * AppConstants.commissionRate;
      final netEarnings = (data['netEarnings'] as num?)?.toDouble() ??
          totalEarnings - commissionPaid;
      final totalRides = (data['totalRides'] as num?)?.toInt() ?? 0;
      final onlineHours = (data['onlineHours'] as num?)?.toDouble() ?? 0.0;

      final dailyData = (data['dailyBreakdown'] as List<dynamic>?) ?? [];
      final dailyBreakdown = dailyData.map((d) {
        final map = d as Map<String, dynamic>;
        return DailyEarning(
          date: map['date'] != null
              ? DateTime.parse(map['date'] as String)
              : DateTime.now(),
          amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
          rides: (map['rides'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      final ridesData = (data['rides'] as List<dynamic>?) ?? [];
      final rides = ridesData
          .map((r) => RideModel.fromJson(r as Map<String, dynamic>))
          .toList();

      _summary = EarningsSummary(
        totalEarnings: totalEarnings,
        commissionPaid: commissionPaid,
        netEarnings: netEarnings,
        totalRides: totalRides,
        averagePerRide: totalRides > 0 ? netEarnings / totalRides : 0,
        onlineHours: onlineHours,
        dailyBreakdown: dailyBreakdown,
        recentRides: rides,
      );

      if (_period == EarningsPeriod.today) {
        _todayEarnings = netEarnings;
      }

      _hasLoaded = true;
    } catch (e) {
      _errorMessage = e is ApiException ? e.message : e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTodayEarnings() async {
    try {
      final data = await _api.getDriverEarnings(period: 'today');
      final net = (data['netEarnings'] as num?)?.toDouble() ?? 0.0;
      _todayEarnings = net;
      notifyListeners();
    } catch (_) {}
  }

  void setPeriod(EarningsPeriod period) {
    if (_period != period) {
      _period = period;
      loadEarnings(period);
    }
  }

  void addEarningFromRide(double amount) {
    _todayEarnings += amount;
    notifyListeners();
  }
}
