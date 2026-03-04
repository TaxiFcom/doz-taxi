import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../../providers/earnings_provider.dart';

/// Summary cards row showing earnings metrics.
class EarningsSummaryCards extends StatelessWidget {
  final EarningsSummary? summary;
  final bool isLoading;

  const EarningsSummaryCards({
    super.key,
    required this.summary,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;

    if (isLoading) {
      return const Center(child: DozLoading());
    }

    if (summary == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: l.t('totalEarnings'),
                value: DozFormatters.currency(summary!.totalEarnings),
                icon: Icons.trending_up,
                color: DozColors.primaryGreen,
                isAr: isAr,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: l.t('ridesCompleted'),
                value: '${summary!.totalRides}',
                icon: Icons.directions_car_outlined,
                color: DozColors.info,
                isAr: isAr,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: isAr ? 'العمولة المدفوعة' : 'Commission Paid',
                value: DozFormatters.currency(summary!.commissionPaid),
                icon: Icons.percent,
                color: DozColors.warning,
                isAr: isAr,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: isAr ? 'صافي الأرباح' : 'Net Earnings',
                value: DozFormatters.currency(summary!.netEarnings),
                icon: Icons.account_balance_wallet_outlined,
                color: DozColors.success,
                isAr: isAr,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: isAr ? 'متوسط الرحلة' : 'Avg per Ride',
                value: DozFormatters.currency(summary!.averagePerRide),
                icon: Icons.bar_chart,
                color: DozColors.primaryGreen,
                isAr: isAr,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: isAr ? 'ساعات العمل' : 'Online Hours',
                value: '${summary!.onlineHours.toStringAsFixed(1)}h',
                icon: Icons.access_time,
                color: DozColors.info,
                isAr: isAr,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isAr;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DozColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DozColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: DozTextStyles.priceMedium(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: DozTextStyles.caption(isArabic: isAr),
          ),
        ],
      ),
    );
  }
}
