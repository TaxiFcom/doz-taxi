import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../widgets/admin_scaffold.dart';

class RevenueReportScreen extends StatefulWidget {
  const RevenueReportScreen({super.key});

  @override
  State<RevenueReportScreen> createState() => _RevenueReportScreenState();
}

class _RevenueReportScreenState extends State<RevenueReportScreen> {
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  String _groupBy = 'day'; // day, week, month
  bool _isLoading = false;

  // Mock data for demonstration
  final List<Map<String, dynamic>> _topDrivers = [
    {'name': 'Ahmed Al-Zaidi', 'earnings': 245.600, 'rides': 42, 'rating': 4.9},
    {'name': 'Omar Hassan', 'earnings': 198.200, 'rides': 38, 'rating': 4.8},
    {'name': 'Khalid Nasser', 'earnings': 175.000, 'rides': 31, 'rating': 4.7},
    {'name': 'Yousef Ibrahim', 'earnings': 156.800, 'rides': 28, 'rating': 4.9},
    {'name': 'Faris Al-Ahmad', 'earnings': 134.500, 'rides': 24, 'rating': 4.6},
  ];

  final List<Map<String, dynamic>> _byVehicleType = [
    {'type': 'Economy', 'revenue': 1240.500, 'rides': 280, 'color': 0xFF7ED321},
    {'type': 'Standard', 'revenue': 980.200, 'rides': 185, 'color': 0xFF3B82F6},
    {'type': 'Premium', 'revenue': 650.000, 'rides': 89, 'color': 0xFF8B5CF6},
    {'type': 'XL/Van', 'revenue': 420.300, 'rides': 42, 'color': 0xFFF59E0B},
  ];

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Revenue Report',
      actions: [
        ElevatedButton.icon(
          onPressed: _pickDateRange,
          icon: const Icon(Icons.calendar_today, size: 14),
          label: Text(
            '${DozFormatters.dateShort(_range.start)} – ${DozFormatters.dateShort(_range.end)}',
            style: const TextStyle(fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: DozColors.surfaceLight,
            foregroundColor: DozColors.textSecondaryLight,
            side: const BorderSide(color: DozColors.borderLight),
            minimumSize: const Size(180, 36),
          ),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector + summary
            _PeriodSelector(
              selected: _groupBy,
              onSelect: (v) => setState(() => _groupBy = v),
            ),
            const SizedBox(height: 20),

            // Revenue breakdown
            _RevenueBreakdown(byVehicleType: _byVehicleType),
            const SizedBox(height: 24),

            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pie chart
                    Expanded(
                      flex: 2,
                      child: _VehicleTypePieChart(data: _byVehicleType),
                    ),
                    const SizedBox(width: 20),
                    // Vehicle type table
                    Expanded(
                      flex: 3,
                      child: _VehicleTypeTable(data: _byVehicleType),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _VehicleTypePieChart(data: _byVehicleType),
                  const SizedBox(height: 20),
                  _VehicleTypeTable(data: _byVehicleType),
                ],
              );
            }),
            const SizedBox(height: 24),

            // Top earning drivers
            _TopDriversTable(drivers: _topDrivers),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _range,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: DozColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _range = picked);
    }
  }
}

class _PeriodSelector extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;

  const _PeriodSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Group by:',
          style: TextStyle(
            fontSize: 13,
            color: DozColors.textMutedLight,
          ),
        ),
        const SizedBox(width: 12),
        _GroupByBtn(
            label: 'Day', value: 'day', selected: selected, onSelect: onSelect),
        const SizedBox(width: 8),
        _GroupByBtn(
            label: 'Week',
            value: 'week',
            selected: selected,
            onSelect: onSelect),
        const SizedBox(width: 8),
        _GroupByBtn(
            label: 'Month',
            value: 'month',
            selected: selected,
            onSelect: onSelect),
      ],
    );
  }
}

class _GroupByBtn extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final void Function(String) onSelect;

  const _GroupByBtn({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? DozColors.primaryGreen
              : DozColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? DozColors.primaryGreen : DozColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : DozColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}

class _RevenueBreakdown extends StatelessWidget {
  final List<Map<String, dynamic>> byVehicleType;
  const _RevenueBreakdown({required this.byVehicleType});

  @override
  Widget build(BuildContext context) {
    final totalRevenue =
        byVehicleType.fold(0.0, (s, v) => s + (v['revenue'] as double));
    final totalCommission = totalRevenue * 0.15;
    final totalRides = byVehicleType.fold(0, (s, v) => s + (v['rides'] as int));
    final topUps = 240.800;
    final refunds = 18.200;

    final items = [
      _BreakdownItem(
        label: 'Total Ride Payments',
        value: totalRevenue,
        color: DozColors.primaryGreen,
      ),
      _BreakdownItem(
        label: 'Commission Earned (15%)',
        value: totalCommission,
        color: DozColors.success,
      ),
      _BreakdownItem(
        label: 'Wallet Top-ups',
        value: topUps,
        color: DozColors.info,
      ),
      _BreakdownItem(
        label: 'Refunds Issued',
        value: refunds,
        color: DozColors.error,
        isNegative: true,
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 800;
      if (isWide) {
        return Row(
          children: items.map((item) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: items.last == item ? 0 : 12),
                child: _BreakdownCard(item: item),
              ),
            );
          }).toList(),
        );
      }
      return Column(
        children: items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _BreakdownCard(item: item),
        )).toList(),
      );
    });
  }
}

class _BreakdownItem {
  final String label;
  final double value;
  final Color color;
  final bool isNegative;
  const _BreakdownItem({
    required this.label,
    required this.value,
    required this.color,
    this.isNegative = false,
  });
}

class _BreakdownCard extends StatelessWidget {
  final _BreakdownItem item;
  const _BreakdownCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DozColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DozColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${item.isNegative ? '-' : ''}${item.value.toStringAsFixed(3)} JOD',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: item.isNegative ? DozColors.error : DozColors.textPrimaryLight,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 12,
              color: DozColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleTypePieChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _VehicleTypePieChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.fold(0.0, (s, v) => s + (v['revenue'] as double));
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
            'Revenue by Vehicle Type',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: DozColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: data.map((d) {
                  final pct = (d['revenue'] as double) / total;
                  return PieChartSectionData(
                    color: Color(d['color'] as int),
                    value: d['revenue'] as double,
                    title: '${(pct * 100).toStringAsFixed(0)}%',
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...data.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Color(d['color'] as int),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        d['type'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: DozColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    Text(
                      '${(d['revenue'] as double).toStringAsFixed(3)} JOD',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DozColors.textPrimaryLight,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _VehicleTypeTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _VehicleTypeTable({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DozColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DozColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Revenue Breakdown',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: DozColors.textPrimaryLight,
              ),
            ),
          ),
          const Divider(height: 1, color: DozColors.borderLight),
          DataTable(
            headingRowColor:
                WidgetStateProperty.all(DozColors.backgroundLight),
            headingTextStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: DozColors.textMutedLight,
            ),
            dataTextStyle: const TextStyle(
              fontSize: 13,
              color: DozColors.textSecondaryLight,
            ),
            columnSpacing: 24,
            horizontalMargin: 16,
            columns: const [
              DataColumn(label: Text('VEHICLE TYPE')),
              DataColumn(label: Text('REVENUE'), numeric: true),
              DataColumn(label: Text('RIDES'), numeric: true),
              DataColumn(label: Text('AVG PRICE'), numeric: true),
            ],
            rows: data.map((d) {
              final avgPrice =
                  (d['revenue'] as double) / (d['rides'] as int);
              return DataRow(cells: [
                DataCell(Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Color(d['color'] as int),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(d['type'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                )),
                DataCell(Text(
                  '${(d['revenue'] as double).toStringAsFixed(3)} JOD',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    color: DozColors.primaryGreen,
                  ),
                )),
                DataCell(Text('${d['rides']}')),
                DataCell(Text('${avgPrice.toStringAsFixed(3)} JOD')),
              ]);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TopDriversTable extends StatelessWidget {
  final List<Map<String, dynamic>> drivers;
  const _TopDriversTable({required this.drivers});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DozColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DozColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Top Earning Drivers',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: DozColors.textPrimaryLight,
              ),
            ),
          ),
          const Divider(height: 1, color: DozColors.borderLight),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  WidgetStateProperty.all(DozColors.backgroundLight),
              headingTextStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: DozColors.textMutedLight,
              ),
              columnSpacing: 24,
              horizontalMargin: 16,
              columns: const [
                DataColumn(label: Text('RANK')),
                DataColumn(label: Text('DRIVER')),
                DataColumn(label: Text('EARNINGS'), numeric: true),
                DataColumn(label: Text('RIDES'), numeric: true),
                DataColumn(label: Text('RATING'), numeric: true),
              ],
              rows: drivers.asMap().entries.map((e) {
                final d = e.value;
                final rank = e.key + 1;
                return DataRow(cells: [
                  DataCell(
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: rank <= 3
                            ? [
                                DozColors.warning,
                                const Color(0xFF9CA3AF),
                                const Color(0xFFCD7F32)
                              ][rank - 1]
                            : DozColors.backgroundLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color:
                                rank <= 3 ? Colors.white : DozColors.textMutedLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(
                    d['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  )),
                  DataCell(Text(
                    '${(d['earnings'] as double).toStringAsFixed(3)} JOD',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: DozColors.success,
                      fontFamily: 'Inter',
                    ),
                  )),
                  DataCell(Text('${d['rides']}')),
                  DataCell(Row(
                    children: [
                      const Icon(Icons.star, size: 13, color: DozColors.warning),
                      const SizedBox(width: 3),
                      Text(
                        (d['rating'] as double).toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
