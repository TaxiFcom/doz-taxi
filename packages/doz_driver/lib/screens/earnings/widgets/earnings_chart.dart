import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../../providers/earnings_provider.dart';

/// Bar chart showing daily earnings for the last 7 days.
class EarningsChart extends StatelessWidget {
  final List<DailyEarning> data;

  const EarningsChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;

    if (data.isEmpty) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        child: Text(
          l.t('noData'),
          style: DozTextStyles.bodySmall(
              isArabic: isAr, color: DozColors.textMuted),
        ),
      );
    }

    final maxY = data.map((d) => d.amount).fold(0.0, (a, b) => a > b ? a : b);
    final adjustedMax = maxY == 0 ? 10.0 : maxY * 1.2;

    return Container(
      height: 180,
      padding: const EdgeInsets.only(top: 8, right: 8),
      child: BarChart(
        BarChartData(
          maxY: adjustedMax,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => DozColors.cardDark,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final d = data[groupIndex];
                return BarTooltipItem(
                  DozFormatters.currency(d.amount),
                  DozTextStyles.caption(isArabic: false)
                      .copyWith(color: DozColors.primaryGreen),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i >= 0 && i < data.length) {
                    final date = data[i].date;
                    final dayNames = isAr
                        ? ['أح', 'إث', 'ثل', 'أر', 'خم', 'جم', 'سب']
                        : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                    return Text(
                      dayNames[date.weekday % 7],
                      style: DozTextStyles.caption(isArabic: isAr),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 28,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            horizontalInterval: adjustedMax / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: DozColors.borderDark,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
            drawVerticalLine: false,
          ),
          barGroups: data.asMap().entries.map((e) {
            final i = e.key;
            final d = e.value;
            final isToday = d.date.day == DateTime.now().day &&
                d.date.month == DateTime.now().month;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: d.amount,
                  color: isToday
                      ? DozColors.primaryGreen
                      : DozColors.primaryGreen.withOpacity(0.4),
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
