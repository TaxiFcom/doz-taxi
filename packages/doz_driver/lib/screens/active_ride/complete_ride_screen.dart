import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/ride_provider.dart';
import '../../providers/earnings_provider.dart';
import '../../navigation/app_router.dart';

/// Complete ride screen — shows earnings breakdown after completing the trip.
class CompleteRideScreen extends StatefulWidget {
  const CompleteRideScreen({super.key});

  @override
  State<CompleteRideScreen> createState() => _CompleteRideScreenState();
}

class _CompleteRideScreenState extends State<CompleteRideScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ride = context.read<RideProvider>().currentRide;
      if (ride != null) {
        final net = (ride.finalPrice ?? ride.suggestedPrice) *
            (1 - AppConstants.commissionRate);
        context.read<EarningsProvider>().addEarningFromRide(net);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final ride = context.watch<RideProvider>();
    final r = ride.currentRide;

    final fare = r?.finalPrice ?? r?.suggestedPrice ?? 0.0;
    final commission = fare * AppConstants.commissionRate;
    final netEarnings = fare - commission;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: DozColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: DozColors.primaryGreen.withOpacity(0.4),
                          blurRadius: 32,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: DozColors.primaryDark,
                      size: 52,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnim,
                child: Text(
                  isAr ? 'اكتملت الرحلة! 🎉' : 'Ride Completed! 🎉',
                  style: DozTextStyles.pageTitle(isArabic: isAr),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              DozCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'تفاصيل الأرباح' : 'Earnings Breakdown',
                      style: DozTextStyles.labelLarge(isArabic: isAr),
                    ),
                    const SizedBox(height: 16),
                    _earningsRow(isAr ? 'قيمة الرحلة' : 'Ride Fare',
                        DozFormatters.currency(fare), DozColors.textPrimary, isAr),
                    const SizedBox(height: 10),
                    _earningsRow(
                        isAr ? 'عمولة المنصة (15%)' : 'Commission (-15%)',
                        '-${DozFormatters.currency(commission)}',
                        DozColors.error, isAr),
                    const Divider(color: DozColors.borderDark, height: 24),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: DozColors.primaryGreenSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: DozColors.primaryGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isAr ? 'أرباحك الصافية' : 'Your Net Earnings',
                            style: DozTextStyles.labelLarge(
                                isArabic: isAr,
                                color: DozColors.primaryGreen),
                          ),
                          Text(
                            DozFormatters.currency(netEarnings),
                            style: DozTextStyles.priceLarge(
                                color: DozColors.primaryGreen),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (r != null)
                      Row(
                        children: [
                          const Icon(Icons.payment,
                              color: DozColors.textMuted, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            r.paymentMethod == PaymentMethod.cash
                                ? (isAr ? 'دفع نقدي' : 'Cash payment')
                                : (isAr ? 'دفع بالمحفظة' : 'Wallet payment'),
                            style: DozTextStyles.bodySmall(
                                isArabic: isAr, color: DozColors.textMuted),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const Spacer(),
              DozButton(
                label: l.t('rateRider'),
                onPressed: () {
                  ride.proceedToRating();
                  context.pushReplacement(AppRoutes.rateRider);
                },
              ),
              const SizedBox(height: 12),
              DozButton(
                label: isAr ? 'الذهاب للرئيسية' : 'Go to Home',
                variant: DozButtonVariant.ghost,
                height: 44,
                onPressed: () {
                  ride.skipRating();
                  context.go(AppRoutes.home);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _earningsRow(String label, String value, Color valueColor, bool isAr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: DozTextStyles.bodyMedium(
                isArabic: isAr, color: DozColors.textSecondary)),
        Text(value,
            style: DozTextStyles.bodyMedium(
                isArabic: false, color: valueColor)),
      ],
    );
  }
}
