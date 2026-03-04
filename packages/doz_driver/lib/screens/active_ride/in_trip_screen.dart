import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/ride_provider.dart';
import '../../navigation/app_router.dart';
import '../home/widgets/navigation_view.dart';

/// In-trip screen — active ride to destination with live navigation.
class InTripScreen extends StatelessWidget {
  const InTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final ride = context.watch<RideProvider>();
    final r = ride.currentRide;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: DozColors.primaryGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.navigation, color: DozColors.primaryDark, size: 16),
              const SizedBox(width: 6),
              Text(
                isAr ? 'الرحلة جارية' : 'Trip in progress',
                style: DozTextStyles.buttonSmall(isArabic: isAr)
                    .copyWith(color: DozColors.primaryDark),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Container(
              decoration: BoxDecoration(
                color: DozColors.error.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => _showSosDialog(context, l, isAr),
                icon: const Icon(Icons.sos, color: Colors.white, size: 20),
                tooltip: 'SOS',
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const NavigationView(showDropoffRoute: true),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(context, r, ride, isAr, l),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, RideModel? r, RideProvider ride,
      bool isAr, AppLocalizations l) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat(Icons.timer_outlined, ride.tripDuration, isAr ? 'الوقت' : 'Time',
                  DozColors.primaryGreen, isAr),
              Container(width: 1, height: 40, color: DozColors.borderDark),
              _stat(
                  Icons.route_outlined,
                  r?.distanceKm != null
                      ? DozFormatters.distance(r!.distanceKm!)
                      : '--',
                  isAr ? 'المسافة' : 'Distance',
                  DozColors.textPrimary,
                  isAr),
              Container(width: 1, height: 40, color: DozColors.borderDark),
              _stat(
                  Icons.attach_money,
                  DozFormatters.currency(r?.finalPrice ?? r?.suggestedPrice ?? 0),
                  isAr ? 'القيمة' : 'Fare',
                  DozColors.primaryGreen,
                  isAr),
            ],
          ),
          const SizedBox(height: 16),
          if (r != null)
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: DozColors.error.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flag, color: DozColors.error, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isAr ? 'الوجهة' : 'Destination',
                          style: DozTextStyles.caption(isArabic: isAr)),
                      Text(r.dropoffAddress,
                          style: DozTextStyles.bodySmall(isArabic: isAr),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          DozButton(
            label: l.t('completeRide'),
            loading: ride.isLoading,
            onPressed: () async {
              final ok = await ride.completeRide();
              if (ok && context.mounted) {
                context.pushReplacement(AppRoutes.completeRide);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label, Color color, bool isAr) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: DozTextStyles.labelLarge(isArabic: false).copyWith(color: color)),
        Text(label, style: DozTextStyles.caption(isArabic: isAr)),
      ],
    );
  }

  void _showSosDialog(BuildContext context, AppLocalizations l, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DozColors.cardDark,
        title: Text(isAr ? 'إرسال نداء استغاثة' : 'Send SOS',
            style: DozTextStyles.sectionTitle(isArabic: isAr)
                .copyWith(color: DozColors.error)),
        content: Text(
            isAr
                ? 'هل تريد إرسال نداء استغاثة إلى فريق الدعم؟'
                : 'Do you want to send an emergency alert to the support team?',
            style: DozTextStyles.bodyMedium(isArabic: isAr)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.t('cancel'),
                style: DozTextStyles.buttonSmall(isArabic: isAr)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'إرسال SOS' : 'Send SOS',
                style: DozTextStyles.buttonSmall(
                    isArabic: isAr, color: DozColors.error)),
          ),
        ],
      ),
    );
  }
}
