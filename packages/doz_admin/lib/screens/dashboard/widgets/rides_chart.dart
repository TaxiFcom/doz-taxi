import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../../providers/dashboard_provider.dart';

class RidesChart extends StatelessWidget {
  final List<RidesDataPoint> data;

  const RidesChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _buildEmpty();

    final maxY = data.map((d) => d.count.toDouble()).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DozColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DozColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rides (Last 7 Days)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: DozColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.3,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY / 4).clamp(1, double.infinity),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: DozColors.borderLightSubtle,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= data.length) return const SizedBox();
                        final date = data[idx].date;
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final day = days[date.weekday - 1];
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontSize: 10,
                              color: DozColors.textMutedLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: (maxY / 4).clamp(1, double.infinity),
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: DozColors.textMutedLight,
                        ),
                      ),
                    ),
                  ),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: data.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.count.toDouble(),
                        color: DozColors.primaryGreen,
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY * 1.3,
                          color: DozColors.primaryGreenSurface,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DozColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DozColors.borderLight),
      ),
      child: const Center(
        child: Text(
          'No ride data available',
          style: TextStyle(color: DozColors.textMutedLight, fontSize: 13),
        ),
      ),
    );
  }
}
