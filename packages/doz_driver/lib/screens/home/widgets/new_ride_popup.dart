import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../../providers/ride_provider.dart';
import '../../../navigation/app_router.dart';

/// Full-screen animated popup for incoming ride requests.
class NewRidePopup extends StatefulWidget {
  const NewRidePopup({super.key});

  @override
  State<NewRidePopup> createState() => _NewRidePopupState();
}

class _NewRidePopupState extends State<NewRidePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutQuint));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final rideProvider = context.watch<RideProvider>();
    final ride = rideProvider.currentRide;
    if (ride == null) return const SizedBox.shrink();
    final timerSeconds = rideProvider.requestTimerSeconds;
    final timerProgress = timerSeconds / 30.0;

    return SlideTransition(
      position: _slideAnim,
      child: Container(
        decoration: const BoxDecoration(
          color: DozColors.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(color: DozColors.borderDark, borderRadius: BorderRadius.circular(2)),
            ),
            Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: DozColors.borderDark),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: timerProgress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: timerSeconds > 10 ? DozColors.primaryGreen : DozColors.error,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(l.t('newRideRequest'), style: DozTextStyles.sectionTitle(isArabic: isAr))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: timerSeconds > 10 ? DozColors.primaryGreenSurface : DozColors.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: timerSeconds > 10 ? DozColors.primaryGreen.withOpacity(0.5) : DozColors.error.withOpacity(0.4)),
                        ),
                        child: Text('${timerSeconds}s',
                          style: DozTextStyles.labelMedium(isArabic: false).copyWith(
                            color: timerSeconds > 10 ? DozColors.primaryGreen : DozColors.error,
                            fontWeight: FontWeight.w700,
                          )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (ride.rider != null)
                    Row(
                      children: [
                        DozAvatar(imageUrl: ride.rider!.avatarUrl, name: ride.rider!.name, size: 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ride.rider!.name, style: DozTextStyles.labelLarge(isArabic: isAr)),
                              Row(children: [
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text('4.8', style: DozTextStyles.caption(isArabic: false)),
                              ]),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(isAr ? 'السعر المقترح' : 'Suggested', style: DozTextStyles.caption(isArabic: isAr)),
                            Text(DozFormatters.currency(ride.suggestedPrice), style: DozTextStyles.priceMedium(color: DozColors.primaryGreen)),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  const Divider(color: DozColors.borderDark),
                  const SizedBox(height: 16),
                  _addressRow(icon: Icons.location_on, iconColor: DozColors.primaryGreen, label: isAr ? 'نقطة الانطلاق' : 'Pickup', address: ride.pickupAddress, isAr: isAr),
                  const SizedBox(height: 12),
                  _addressRow(icon: Icons.flag, iconColor: DozColors.error, label: isAr ? 'نقطة الوصول' : 'Drop-off', address: ride.dropoffAddress, isAr: isAr),
                  const SizedBox(height: 16),
                  if (ride.distanceKm != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: DozColors.cardDark, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _infoChip(Icons.route_outlined, DozFormatters.distance(ride.distanceKm!), isAr ? 'المسافة' : 'Distance', isAr),
                          if (ride.durationMin != null)
                            _infoChip(Icons.access_time_outlined, DozFormatters.duration(ride.durationMin!), isAr ? 'الوقت' : 'Duration', isAr),
                          _infoChip(Icons.account_balance_wallet_outlined,
                            ride.paymentMethod == PaymentMethod.cash ? (isAr ? 'نقدي' : 'Cash') : (isAr ? 'محفظة' : 'Wallet'),
                            isAr ? 'الدفع' : 'Payment', isAr),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: DozButton(label: isAr ? 'رفض' : 'Decline', variant: DozButtonVariant.outlined, onPressed: () => context.read<RideProvider>().declineRequest())),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: DozButton(label: l.t('placeBid'), onPressed: () {
                        context.read<RideProvider>().openBidScreen();
                        context.push(AppRoutes.placeBid);
                      })),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressRow({required IconData icon, required Color iconColor, required String label, required String address, required bool isAr}) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: DozTextStyles.caption(isArabic: isAr)),
              Text(address, style: DozTextStyles.bodySmall(isArabic: isAr, color: DozColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String value, String label, bool isAr) {
    return Column(
      children: [
        Icon(icon, color: DozColors.textMuted, size: 18),
        const SizedBox(height: 4),
        Text(value, style: DozTextStyles.labelMedium(isArabic: false).copyWith(color: DozColors.textPrimary)),
        Text(label, style: DozTextStyles.caption(isArabic: isAr)),
      ],
    );
  }
}
