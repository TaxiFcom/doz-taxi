import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/rides_provider.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/data_table_widget.dart';
import '../../widgets/search_filter_bar.dart';
import '../../widgets/confirm_dialog.dart';
import 'ride_detail_dialog.dart';

class RidesScreen extends StatefulWidget {
  const RidesScreen({super.key});

  @override
  State<RidesScreen> createState() => _RidesScreenState();
}

class _RidesScreenState extends State<RidesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RidesProvider>().loadRides(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Rides',
      actions: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Export'),
          style: ElevatedButton.styleFrom(
            backgroundColor: DozColors.surfaceLight,
            foregroundColor: DozColors.textSecondaryLight,
            side: const BorderSide(color: DozColors.borderLight),
            minimumSize: const Size(100, 36),
          ),
        ),
      ],
      child: Consumer<RidesProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _RidesFilterBar(provider: provider),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: DozColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: DozColors.borderLight),
                    ),
                    child: AdminDataTable<RideModel>(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('RIDER')),
                        DataColumn(label: Text('DRIVER')),
                        DataColumn(label: Text('PICKUP')),
                        DataColumn(label: Text('DROPOFF')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('PRICE'), numeric: true),
                        DataColumn(label: Text('PAYMENT')),
                        DataColumn(label: Text('DATE')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rows: provider.rides,
                      rowBuilder: (ride, index) => DataRow(
                        onSelectChanged: (_) => _showRideDetail(context, ride),
                        cells: [
                          DataCell(Text('#${ride.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontSize: 11, fontFamily: 'RobotoMono', color: DozColors.textMutedLight))),
                          DataCell(Text(ride.rider?.name ?? ride.riderId.substring(0, 8), style: const TextStyle(fontWeight: FontWeight.w500))),
                          DataCell(Text(ride.driver?.user?.name ?? (ride.driverId != null ? ride.driverId!.substring(0, 8) : '—'))),
                          DataCell(SizedBox(width: 120, child: Text(ride.pickupAddress, overflow: TextOverflow.ellipsis))),
                          DataCell(SizedBox(width: 120, child: Text(ride.dropoffAddress, overflow: TextOverflow.ellipsis))),
                          DataCell(StatusBadge.forRideStatus(ride.status)),
                          DataCell(Text('${(ride.finalPrice ?? ride.suggestedPrice).toStringAsFixed(3)} JOD', style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'))),
                          DataCell(_PaymentBadge(method: ride.paymentMethod)),
                          DataCell(Text(DozFormatters.dateShort(ride.createdAt), style: const TextStyle(fontSize: 11))),
                          DataCell(IconButton(onPressed: () => _showRideDetail(context, ride), icon: const Icon(Icons.open_in_new, size: 16), color: DozColors.primaryGreen, tooltip: 'View details')),
                        ],
                      ),
                      isLoading: provider.isLoading,
                      emptyMessage: 'No rides found',
                      currentPage: provider.currentPage,
                      totalPages: provider.totalPages,
                      totalItems: provider.totalCount,
                      pageSize: 20,
                      onPageChanged: provider.goToPage,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRideDetail(BuildContext context, RideModel ride) {
    showDialog(context: context, builder: (_) => RideDetailDialog(ride: ride));
  }
}

class _RidesFilterBar extends StatelessWidget {
  final RidesProvider provider;
  const _RidesFilterBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final statuses = [('All', null), ('Pending', 'pending'), ('Active', 'in_progress'), ('Completed', 'completed'), ('Cancelled', 'cancelled')];
    return SearchFilterBar(
      hintText: 'Search by rider, driver, address...',
      onSearch: provider.setSearchQuery,
      chips: statuses.map((s) => FilterChipData(label: s.$1, isSelected: provider.statusFilter == s.$2, onTap: () => provider.setStatusFilter(s.$2))).toList(),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final PaymentMethod method;
  const _PaymentBadge({required this.method});

  @override
  Widget build(BuildContext context) {
    Color color, bg;
    String label;
    IconData icon;
    switch (method) {
      case PaymentMethod.cash: color = DozColors.warning; bg = DozColors.warningLight; label = 'Cash'; icon = Icons.money; break;
      case PaymentMethod.wallet: color = DozColors.info; bg = DozColors.infoLight; label = 'Wallet'; icon = Icons.account_balance_wallet; break;
      case PaymentMethod.card: color = DozColors.statusBidding; bg = const Color(0xFFEDE9FE); label = 'Card'; icon = Icons.credit_card; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
