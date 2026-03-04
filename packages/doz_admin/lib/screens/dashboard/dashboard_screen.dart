import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/admin_scaffold.dart';
import 'widgets/stat_card.dart';
import 'widgets/revenue_chart.dart';
import 'widgets/rides_chart.dart';
import 'widgets/recent_rides_table.dart';
import 'widgets/active_drivers_map.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Dashboard',
      actions: [
        ElevatedButton.icon(
          onPressed: () => context.read<DashboardProvider>().loadDashboard(),
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Refresh'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(100, 36),
          ),
        ),
      ],
      child: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(DozColors.primaryGreen),
              ),
            );
          }
          if (provider.error != null) {
            return _ErrorView(
              error: provider.error!,
              onRetry: () => provider.loadDashboard(),
            );
          }
          return _DashboardContent(stats: provider.stats);
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardStats stats;
  const _DashboardContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          Text(
            'Good ${_getTimeOfDay()}, Admin',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: DozColors.textPrimaryLight,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Here\'s what\'s happening with DOZ Taxi today.',
            style: const TextStyle(
              fontSize: 13,
              color: DozColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 24),

          // Stat cards (2 rows of 3)
          _StatCardsGrid(stats: stats),
          const SizedBox(height: 24),

          // Charts row
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: RevenueChart(data: stats.revenueChart),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        RidesChart(data: stats.ridesChart),
                        const SizedBox(height: 16),
                        ActiveDriversMap(
                            activeDrivers: stats.onlineDrivers),
                      ],
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                RevenueChart(data: stats.revenueChart),
                const SizedBox(height: 16),
                RidesChart(data: stats.ridesChart),
                const SizedBox(height: 16),
                ActiveDriversMap(activeDrivers: stats.onlineDrivers),
              ],
            );
          }),
          const SizedBox(height: 24),

          // Recent rides
          RecentRidesTable(rides: stats.recentRides),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _StatCardsGrid extends StatelessWidget {
  final DashboardStats stats;
  const _StatCardsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final cards = [
      StatCard(
        title: 'Total Rides',
        value: stats.totalRides.toString(),
        subtitle: '${stats.todayRides} today',
        icon: Icons.directions_car,
        color: DozColors.primaryGreen,
        bgColor: DozColors.primaryGreenSurface,
        change: 12.5,
      ),
      StatCard(
        title: 'Active Rides',
        value: stats.activeRides.toString(),
        subtitle: 'Live now',
        icon: Icons.radio_button_checked,
        color: DozColors.info,
        bgColor: DozColors.infoLight,
      ),
      StatCard(
        title: 'Total Riders',
        value: stats.totalRiders.toString(),
        subtitle: 'Registered users',
        icon: Icons.people,
        color: DozColors.statusBidding,
        bgColor: const Color(0xFFEDE9FE),
        change: 5.2,
      ),
      StatCard(
        title: 'Total Drivers',
        value: stats.totalDrivers.toString(),
        subtitle: '${stats.onlineDrivers} online',
        icon: Icons.drive_eta,
        color: DozColors.warning,
        bgColor: DozColors.warningLight,
        change: 3.8,
      ),
      StatCard(
        title: 'Total Revenue',
        value:
            '${stats.totalRevenue.toStringAsFixed(0)} JOD',
        subtitle: 'All time',
        icon: Icons.account_balance_wallet,
        color: DozColors.success,
        bgColor: DozColors.successLight,
        change: 18.3,
      ),
      StatCard(
        title: 'Today\'s Revenue',
        value:
            '${stats.todayRevenue.toStringAsFixed(3)} JOD',
        subtitle: 'Today',
        icon: Icons.trending_up,
        color: DozColors.error,
        bgColor: DozColors.errorLight,
        change: -2.1,
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      int crossCount = 3;
      if (constraints.maxWidth < 600) crossCount = 1;
      else if (constraints.maxWidth < 900) crossCount = 2;

      return GridView.count(
        crossAxisCount: crossCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: crossCount == 1 ? 3 : 1.6,
        children: cards,
      );
    });
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off,
              size: 48, color: DozColors.textDisabledLight),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(
                fontSize: 14, color: DozColors.textSecondaryLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
