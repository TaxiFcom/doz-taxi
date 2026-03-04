import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../../providers/earnings_provider.dart';

/// Mini earnings bar at the top of the home screen.
class EarningsBar extends StatelessWidget {
  const EarningsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final earnings = context.watch<EarningsProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DozColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DozColors.borderDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: DozColors.primaryGreenSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.attach_money, color: DozColors.primaryGreen, size: 18),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.t('todayEarnings'), style: DozTextStyles.caption(isArabic: isAr, color: DozColors.textMuted)),
              Text(DozFormatters.currency(earnings.todayEarnings), style: DozTextStyles.priceMedium(color: DozColors.primaryGreen)),
            ],
          ),
        ],
      ),
    );
  }
}
