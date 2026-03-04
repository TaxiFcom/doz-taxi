import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../../providers/dashboard_provider.dart';

class RevenueChart extends StatelessWidget {
  final List<RevenueDataPoint> data;

  const RevenueChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmpty();
    }

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.amount);
    }).toList();

    final maxY = data.map((d) => d.amount).reduce((a, b) => a > b ? a : b);
    final minY = 0.0;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Revenue (Last 30 Days)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: DozColors.textPrimaryLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: DozColors.primaryGreenSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'JOD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: DozColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY / 4).clamp(1, double.infinity),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: DozColors.borderLightSubtle,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: (maxY / 4).clamp(1, double.infinity),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value >= 1000
                              ? '${(value / 1000).toStringAsFixed(1)}K'
                              : value.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 10,
                            color: DozColors.textMutedLight,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: (data.length / 6).clamp(1, double.infinity),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= data.length) return const SizedBox();
                        final date = data[idx].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: DozColors.textMutedLight,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: DozColors.primaryGreen,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          DozColors.primaryGreen.withOpacity(0.15),
                          DozColors.primaryGreen.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: minY,
                maxY: maxY * 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DozColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DozColors.borderLight),
      ),
      child: const Center(
        child: Text(
          'No revenue data available',
          style: TextStyle(color: DozColors.textMutedLight, fontSize: 13),
        ),
      ),
    );
  }
}
