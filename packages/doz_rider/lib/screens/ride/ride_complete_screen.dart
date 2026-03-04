import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/ride_provider.dart';
import '../../navigation/app_router.dart';

/// Ride complete screen — fare summary and payment confirmation.
class RideCompleteScreen extends StatefulWidget {
  const RideCompleteScreen({super.key});

  @override
  State<RideCompleteScreen> createState() => _RideCompleteScreenState();
}

class _RideCompleteScreenState extends State<RideCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkAnim;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _checkAnim = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final ride = context.watch<RideProvider>().currentRide;

    final total = ride?.finalPrice ?? ride?.suggestedPrice ?? 0.0;
    final basefare = total * 0.6;
    final distCharge = total * 0.3;
    final timeCharge = total * 0.1;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      body: Container(
        decoration: const BoxDecoration(gradient: DozColors.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                // Success animation
                Center(
                  child: ScaleTransition(
                    scale: _checkAnim,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DozColors.primaryGreenSurface,
                        border: Border.all(
                          color: DozColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: DozColors.primaryGreen,
                        size: 56,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  isArabic ? 'اكتملت الرحلة!' : 'Ride Completed!',
                  style: DozTextStyles.pageTitle(isArabic: isArabic),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  isArabic
                      ? 'شكراً لاستخدامك دوز'
                      : 'Thank you for riding with DOZ',
                  style: DozTextStyles.bodyMedium(
                    isArabic: isArabic,
                    color: DozColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Fare breakdown
                DozCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isArabic ? 'تفاصيل الأجرة' : 'Fare Breakdown',
                        style: DozTextStyles.labelLarge(isArabic: isArabic),
                      ),
                      const SizedBox(height: 16),

                      _FareRow(
                        label: isArabic ? 'الأجرة الأساسية' : 'Base Fare',
                        amount: basefare,
                      ),
                      _FareRow(
                        label: isArabic ? 'رسوم المسافة' : 'Distance Charge',
                        amount: distCharge,
                      ),
                      _FareRow(
                        label: isArabic ? 'رسوم الوقت' : 'Time Charge',
                        amount: timeCharge,
                      ),

                      Divider(height: 20, color: DozColors.borderDark),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isArabic ? 'الإجمالي' : 'Total',
                            style: DozTextStyles.sectionTitle(isArabic: isArabic),
                          ),
                          DozPriceTag(
                            amount: total,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Payment method
                DozCard(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: DozColors.primaryGreenSurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.payments_rounded,
                          color: DozColors.primaryGreen,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'طريقة الدفع' : 'Payment Method',
                            style: DozTextStyles.caption(isArabic: isArabic),
                          ),
                          Text(
                            isArabic ? 'نقداً' : 'Cash',
                            style: DozTextStyles.bodyMedium(isArabic: isArabic)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: DozColors.successLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isArabic ? 'مدفوع' : 'Paid',
                          style: DozTextStyles.caption(
                            isArabic: isArabic,
                            color: DozColors.success,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Rate driver button
                DozButton(
                  label: isArabic ? 'قيّم السائق' : 'Rate Your Driver',
                  onPressed: () {
                    context.push(
                      AppRoutes.rateDriver,
                      extra: ride?.id,
                    );
                  },
                ),

                const SizedBox(height: 12),

                DozButton(
                  label: isArabic ? 'العودة للرئيسية' : 'Back to Home',
                  onPressed: () {
                    context.read<RideProvider>().clearRide();
                    context.go(AppRoutes.home);
                  },
                  variant: DozButtonVariant.ghost,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final double amount;

  const _FareRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: DozTextStyles.bodyMedium(
              isArabic: isArabic,
              color: DozColors.textMuted,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(3)} JOD',
            style: DozTextStyles.bodyMedium(isArabic: false),
          ),
        ],
      ),
    );
  }
}
