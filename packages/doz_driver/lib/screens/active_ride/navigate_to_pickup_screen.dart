import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/ride_provider.dart';
import '../../providers/driver_provider.dart';
import '../../navigation/app_router.dart';
import '../home/widgets/navigation_view.dart';

/// Navigate to pickup screen — map with route to pickup + rider info card.
class NavigateToPickupScreen extends StatelessWidget {
  const NavigateToPickupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final ride = context.watch<RideProvider>();
    final driver = context.watch<DriverProvider>();
    final r = ride.currentRide;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DozColors.cardDark.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new,
                color: DozColors.textPrimary, size: 18),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: DozColors.cardDark.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(l.t('navigateToPickup'),
              style: DozTextStyles.labelLarge(isArabic: isAr)),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const NavigationView(showPickupRoute: true),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(context, r, isAr, l, ride, driver),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, RideModel? r, bool isAr,
      AppLocalizations l, RideProvider ride, DriverProvider driver) {
    return Container(
      decoration: BoxDecoration(
        color: DozColors.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DozColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (r?.rider != null) ...[
            Row(
              children: [
                DozAvatar(
                  imageUrl: r!.rider!.avatarUrl,
                  name: r.rider!.name,
                  size: 48,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.rider!.name,
                          style: DozTextStyles.sectionTitle(isArabic: isAr)),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text('4.8',
                              style: DozTextStyles.caption(isArabic: false)),
                        ],
                      ),
                    ],
                  ),
                ),
                _actionButton(
                  icon: Icons.phone,
                  color: DozColors.success,
                  onTap: () async {
                    final phone = r.rider?.phone;
                    if (phone != null) launchUrl(Uri.parse('tel:$phone'));
                  },
                ),
                const SizedBox(width: 8),
                _actionButton(
                  icon: Icons.message_outlined,
                  color: DozColors.info,
                  onTap: () async {
                    final phone = r.rider?.phone;
                    if (phone != null) launchUrl(Uri.parse('sms:$phone'));
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on,
                    color: DozColors.primaryGreen, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.pickupAddress,
                    style: DozTextStyles.bodySmall(isArabic: isAr),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          DozButton(
            label: l.t('arrivedAtPickup'),
            loading: ride.isLoading,
            onPressed: () async {
              final ok = await ride.confirmArrival();
              if (ok && context.mounted) {
                context.pushReplacement(AppRoutes.atPickup);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
