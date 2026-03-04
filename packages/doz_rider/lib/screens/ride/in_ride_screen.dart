import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/ride_provider.dart';
import '../../navigation/app_router.dart';
import '../home/widgets/map_view.dart';
import 'widgets/driver_info_card.dart';

/// In-ride screen — active ride with live driver tracking and progress.
class InRideScreen extends StatelessWidget {
  const InRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final ride = context.watch<RideProvider>().currentRide;
    final driver = ride?.driver;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      body: Stack(
        children: [
          // Map
          const MapView(showRoute: true, showNearbyDrivers: false),

          // SOS Button (top right)
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showSosDialog(context, isArabic);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: DozColors.error,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: DozColors.error.withOpacity(0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sos_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              'SOS',
                              style: DozTextStyles.buttonSmall(
                                isArabic: false,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Share ride button
                    GestureDetector(
                      onTap: () {
                        // TODO: share ride link
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: DozColors.cardDark.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: DozColors.borderDark),
                        ),
                        child: const Icon(
                          Icons.share_rounded,
                          color: DozColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: DozColors.surfaceDark,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: DozColors.borderDark),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: DozColors.borderDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Destination info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: DozColors.mapDropoff, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ride?.dropoffAddress ?? '',
                            style: DozTextStyles.bodyMedium(isArabic: isArabic)
                                .copyWith(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (ride?.durationMin != null)
                          Text(
                            '~${ride!.durationMin} ${isArabic ? 'د' : 'min'}',
                            style: DozTextStyles.bodyMedium(
                              isArabic: isArabic,
                              color: DozColors.primaryGreen,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: LinearProgressIndicator(
                      value: 0.4,
                      backgroundColor: DozColors.cardDark,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        DozColors.primaryGreen,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Driver info (compact)
                  if (driver != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DriverInfoCard(
                        driver: driver,
                        showActions: false,
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSosDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DozColors.cardDark,
        title: Text(
          isArabic ? 'طوارئ SOS' : 'SOS Emergency',
          style: DozTextStyles.sectionTitle(isArabic: isArabic)
              .copyWith(color: DozColors.error),
        ),
        content: Text(
          isArabic
              ? 'سيتم إخطار جهات الطوارئ وخدمة العملاء بموقعك الحالي.'
              : 'Emergency services and customer support will be notified of your current location.',
          style: DozTextStyles.bodyMedium(isArabic: isArabic),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.of(context).t('cancel'),
              style: const TextStyle(color: DozColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: trigger SOS
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DozColors.error,
            ),
            child: Text(
              isArabic ? 'إرسال SOS' : 'Send SOS',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
