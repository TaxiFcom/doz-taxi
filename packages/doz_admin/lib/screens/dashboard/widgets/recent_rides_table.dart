import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../../widgets/confirm_dialog.dart';

class RecentRidesTable extends StatelessWidget {
  final List<RideModel> rides;

  const RecentRidesTable({super.key, required this.rides});

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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Rides',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: DozColors.textPrimaryLight,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      color: DozColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: DozColors.borderLight),
          if (rides.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No recent rides',
                  style: TextStyle(
                    color: DozColors.textMutedLight,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(DozColors.backgroundLight),
                headingTextStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: DozColors.textMutedLight,
                  letterSpacing: 0.5,
                ),
                dataTextStyle: const TextStyle(
                  fontSize: 12,
                  color: DozColors.textSecondaryLight,
                ),
                dataRowMinHeight: 48,
                dataRowMaxHeight: 56,
                dividerThickness: 1,
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('RIDE ID')),
                  DataColumn(label: Text('RIDER')),
                  DataColumn(label: Text('PICKUP')),
                  DataColumn(label: Text('DROPOFF')),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('PRICE'), numeric: true),
                  DataColumn(label: Text('DATE')),
                ],
                rows: rides.map((ride) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          '#${ride.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 11,
                            color: DozColors.textMutedLight,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          ride.rider?.name ?? 'Rider ${ride.riderId.substring(0, 6)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: Text(
                            ride.pickupAddress,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: Text(
                            ride.dropoffAddress,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(StatusBadge.forRideStatus(ride.status)),
                      DataCell(
                        Text(
                          '${(ride.finalPrice ?? ride.suggestedPrice).toStringAsFixed(3)} JOD',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          DozFormatters.dateShort(ride.createdAt),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
