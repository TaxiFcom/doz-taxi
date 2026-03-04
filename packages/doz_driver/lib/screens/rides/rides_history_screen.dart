import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:doz_shared/doz_shared.dart';

/// Rides history screen with tabs for Today, This Week, and All rides.
class RidesHistoryScreen extends StatefulWidget {
  const RidesHistoryScreen({super.key});

  @override
  State<RidesHistoryScreen> createState() => _RidesHistoryScreenState();
}

class _RidesHistoryScreenState extends State<RidesHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<RideModel> _rides = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRides();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRides() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _isLoading = false);
    } catch (e) { setState(() { _error = e.toString(); _isLoading = false; }); }
  }

  List<RideModel> _getFilteredRides(int tabIndex) {
    final now = DateTime.now();
    switch (tabIndex) {
      case 0: return _rides.where((r) { final d = r.completedAt ?? r.createdAt; return d.year == now.year && d.month == now.month && d.day == now.day; }).toList();
      case 1: final weekStart = now.subtract(Duration(days: now.weekday - 1)); return _rides.where((r) { final d = r.completedAt ?? r.createdAt; return d.isAfter(weekStart); }).toList();
      default: return _rides;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: DozColors.surfaceDark, elevation: 0,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new, color: DozColors.textPrimary, size: 20)),
        title: Text(l.t('rideHistory'), style: DozTextStyles.sectionTitle(isArabic: isAr)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: DozColors.primaryGreen, indicatorWeight: 3,
          labelColor: DozColors.primaryGreen, unselectedLabelColor: DozColors.textMuted,
          labelStyle: DozTextStyles.labelMedium(isArabic: isAr).copyWith(fontWeight: FontWeight.w600),
          tabs: [Tab(text: l.t('today')), Tab(text: isAr ? 'هذا الأسبوع' : 'This Week'), Tab(text: isAr ? 'الكل' : 'All')],
        ),
      ),
      body: _isLoading ? const Center(child: DozLoading())
          : _error != null ? Center(child: DozEmptyState(icon: Icons.error_outline, title: l.t('error'), subtitle: _error!, actionLabel: l.t('retry'), onAction: _loadRides))
          : TabBarView(controller: _tabController, children: List.generate(3, (i) => _buildTab(_getFilteredRides(i), isAr, l))),
    );
  }

  Widget _buildTab(List<RideModel> rides, bool isAr, AppLocalizations l) {
    if (rides.isEmpty) return DozEmptyState(icon: Icons.directions_car_outlined, title: l.t('noRidesYet'), subtitle: isAr ? 'لا توجد رحلات في هذه الفترة' : 'No rides in this period');
    return ListView.builder(padding: const EdgeInsets.all(16), itemCount: rides.length, itemBuilder: (context, i) => _RideCard(ride: rides[i], isAr: isAr, onTap: () => context.push('/rides/${rides[i].id}')));
  }
}

class _RideCard extends StatelessWidget {
  final RideModel ride;
  final bool isAr;
  final VoidCallback onTap;
  const _RideCard({required this.ride, required this.isAr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fare = ride.finalPrice ?? ride.suggestedPrice;
    final net = fare - fare * AppConstants.commissionRate;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: DozColors.surfaceDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: DozColors.borderDark)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(DozFormatters.time(ride.createdAt, lang: isAr ? 'ar' : 'en'), style: DozTextStyles.caption(isArabic: isAr, color: DozColors.textMuted)),
              const SizedBox(width: 8),
              Text(DozFormatters.relativeDate(ride.createdAt, lang: isAr ? 'ar' : 'en'), style: DozTextStyles.caption(isArabic: isAr, color: DozColors.textMuted)),
              const Spacer(),
              DozStatusBadge(label: _statusLabel(ride.status, isAr), backgroundColor: _statusColor(ride.status)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Column(children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: DozColors.primaryGreen, shape: BoxShape.circle)),
                Container(width: 2, height: 24, color: DozColors.borderDark),
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: DozColors.error, shape: BoxShape.circle)),
              ]),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ride.pickupAddress, style: DozTextStyles.bodySmall(isArabic: isAr), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Text(ride.dropoffAddress, style: DozTextStyles.bodySmall(isArabic: isAr), maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
            ]),
            const Divider(color: DozColors.borderDark, height: 20),
            Row(children: [
              if (ride.distanceKm != null) Row(children: [const Icon(Icons.straighten, color: DozColors.textMuted, size: 14), const SizedBox(width: 4), Text(DozFormatters.distance(ride.distanceKm!), style: DozTextStyles.caption(isArabic: isAr))]),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(DozFormatters.currency(net), style: DozTextStyles.priceMedium(color: DozColors.primaryGreen)),
                Text(isAr ? 'صافي الأرباح' : 'Net earnings', style: DozTextStyles.caption(isArabic: isAr)),
              ]),
            ]),
          ],
        ),
      ),
    );
  }

  String _statusLabel(RideStatus status, bool isAr) {
    switch (status) {
      case RideStatus.completed: return isAr ? 'مكتملة' : 'Completed';
      case RideStatus.cancelled: return isAr ? 'ملغاة' : 'Cancelled';
      case RideStatus.inProgress: return isAr ? 'جارية' : 'In Progress';
      default: return status.name;
    }
  }

  Color _statusColor(RideStatus status) {
    switch (status) {
      case RideStatus.completed: return DozColors.success;
      case RideStatus.cancelled: return DozColors.error;
      case RideStatus.inProgress: return DozColors.primaryGreen;
      default: return DozColors.info;
    }
  }
}
