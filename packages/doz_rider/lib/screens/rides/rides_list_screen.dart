import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/ride_provider.dart';
import '../../navigation/app_router.dart';

/// Rides history screen with Active / Completed / Cancelled tabs.
class RidesListScreen extends StatefulWidget {
  const RidesListScreen({super.key});

  @override
  State<RidesListScreen> createState() => _RidesListScreenState();
}

class _RidesListScreenState extends State<RidesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().loadRideHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final rideProvider = context.watch<RideProvider>();

    final activeRides = rideProvider.rideHistory
        .where((r) => r.isActive)
        .toList();
    final completedRides = rideProvider.rideHistory
        .where((r) => r.status == RideStatus.completed)
        .toList();
    final cancelledRides = rideProvider.rideHistory
        .where((r) => r.status == RideStatus.cancelled)
        .toList();

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: DozColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
          color: DozColors.textPrimary,
        ),
        title: Text(
          isArabic ? 'رحلاتي' : 'My Rides',
          style: DozTextStyles.sectionTitle(isArabic: isArabic),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: DozColors.primaryGreen,
          unselectedLabelColor: DozColors.textMuted,
          indicatorColor: DozColors.primaryGreen,
          indicatorWeight: 2,
          labelStyle: DozTextStyles.bodySmall(isArabic: isArabic)
              .copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              DozTextStyles.bodySmall(isArabic: isArabic),
          tabs: [
            Tab(text: isArabic ? 'نشطة' : 'Active'),
            Tab(text: isArabic ? 'مكتملة' : 'Completed'),
            Tab(text: isArabic ? 'ملغية' : 'Cancelled'),
          ],
        ),
      ),
      body: rideProvider.isLoading
          ? const Center(child: DozLoading())
          : TabBarView(
              controller: _tabController,
              children: [
                _RideTab(
                  rides: activeRides,
                  emptyIcon: Icons.hail_rounded,
                  emptyTitle: isArabic ? 'لا توجد رحلات نشطة' : 'No active rides',
                ),
                _RideTab(
                  rides: completedRides,
                  emptyIcon: Icons.check_circle_outline_rounded,
                  emptyTitle:
                      isArabic ? 'لا توجد رحلات مكتملة' : 'No completed rides',
                ),
                _RideTab(
                  rides: cancelledRides,
                  emptyIcon: Icons.cancel_outlined,
                  emptyTitle:
                      isArabic ? 'لا توجد رحلات ملغية' : 'No cancelled rides',
                ),
              ],
            ),
    );
  }
}

class _RideTab extends StatelessWidget {
  final List<RideModel> rides;
  final IconData emptyIcon;
  final String emptyTitle;

  const _RideTab({
    required this.rides,
    required this.emptyIcon,
    required this.emptyTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (rides.isEmpty) {
      return DozEmptyState(icon: emptyIcon, title: emptyTitle);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rides.length,
      itemBuilder: (_, i) => _RideCard(ride: rides[i]),
    );
  }
}

class _RideCard extends StatelessWidget {
  final RideModel ride;

  const _RideCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    return DozCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => context.push('/rides/${ride.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DozFormatters.relativeDate(ride.createdAt,
                    lang: isArabic ? 'ar' : 'en'),
                style: DozTextStyles.caption(isArabic: isArabic),
              ),
              DozStatusBadge.ride(ride.status, context: context),
            ],
          ),

          const SizedBox(height: 12),

          // Route
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: DozColors.mapPickup,
                    ),
                  ),
                  Container(width: 1, height: 20, color: DozColors.borderDark),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: DozColors.mapDropoff,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.pickupAddress,
                      style: DozTextStyles.bodySmall(isArabic: isArabic)
                          .copyWith(color: DozColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ride.dropoffAddress,
                      style: DozTextStyles.bodySmall(isArabic: isArabic)
                          .copyWith(color: DozColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          Divider(height: 16, color: DozColors.borderDark),

          // Driver + price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (ride.driver != null)
                Row(
                  children: [
                    DozAvatar(
                      name: ride.driver!.user?.name ?? '',
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ride.driver!.user?.name ?? '',
                      style: DozTextStyles.bodySmall(isArabic: isArabic)
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                )
              else
                const SizedBox(),
              DozPriceTag(
                amount: ride.finalPrice ?? ride.suggestedPrice,
                style: DozTextStyles.bodyMedium(isArabic: false)
                    .copyWith(fontWeight: FontWeight.w600),
                currencyStyle: DozTextStyles.caption(isArabic: false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
