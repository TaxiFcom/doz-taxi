import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/ride_provider.dart';
import '../../navigation/app_router.dart';
import '../home/widgets/map_view.dart';
import 'widgets/driver_info_card.dart';

/// Driver arriving screen — driver en route to pickup with live tracking.
class DriverArrivingScreen extends StatelessWidget {
  const DriverArrivingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final ride = context.watch<RideProvider>().currentRide;
    final driver = ride?.driver;

    if (driver == null) {
      return const Scaffold(
        backgroundColor: DozColors.primaryDark,
        body: Center(child: DozLoading()),
      );
    }

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      body: Stack(
        children: [
          // Map with driver location
          MapView(
            showNearbyDrivers: false,
            showRoute: false,
          ),

          // Status banner
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: DozColors.statusArriving.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: DozColors.statusArriving.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: DozColors.statusArriving,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isArabic ? 'السائق في الطريق إليك' : 'Driver is on the way',
                    style: DozTextStyles.bodyMedium(
                      isArabic: isArabic,
                      color: DozColors.statusArriving,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
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

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DriverInfoCard(
                      driver: driver,
                      eta: '${isArabic ? '~3 دقائق' : '~3 min'}',
                      onCall: () {
                        // TODO: launch phone call
                      },
                      onMessage: () {
                        // TODO: open chat
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Cancel ride button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DozButton(
                      label: l10n.t('cancel'),
                      onPressed: () async {
                        await context.read<RideProvider>().cancelRide(
                              reason: isArabic
                                  ? 'إلغاء قبل الوصول'
                                  : 'Cancelled before arrival',
                            );
                        if (context.mounted) {
                          context.go(AppRoutes.home);
                        }
                      },
                      variant: DozButtonVariant.outlined,
                      height: 44,
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
}
