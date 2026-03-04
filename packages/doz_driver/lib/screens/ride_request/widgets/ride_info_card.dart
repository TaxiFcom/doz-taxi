import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Compact ride info card for the bid screen.
class RideInfoCard extends StatelessWidget {
  final RideModel ride;

  const RideInfoCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;

    return DozCard(
      child: Column(
        children: [
          _addressRow(icon: Icons.location_on, iconColor: DozColors.primaryGreen, label: isAr ? 'الانطلاق' : 'Pickup', address: ride.pickupAddress, isAr: isAr),
          const SizedBox(height: 8),
          _addressRow(icon: Icons.flag, iconColor: DozColors.error, label: isAr ? 'الوصول' : 'Destination', address: ride.dropoffAddress, isAr: isAr),
          if (ride.distanceKm != null || ride.durationMin != null) ...[
            const Divider(color: DozColors.borderDark, height: 16),
            Row(
              children: [
                if (ride.distanceKm != null) _chip(Icons.straighten, DozFormatters.distance(ride.distanceKm!)),
                const SizedBox(width: 12),
                if (ride.durationMin != null) _chip(Icons.access_time, DozFormatters.duration(ride.durationMin!)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _addressRow({required IconData icon, required Color iconColor, required String label, required String address, required bool isAr}) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: DozTextStyles.caption(isArabic: isAr)),
          Text(address, style: DozTextStyles.bodySmall(isArabic: isAr), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
      ],
    );
  }

  Widget _chip(IconData icon, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: DozColors.textMuted, size: 14),
      const SizedBox(width: 4),
      Text(label, style: DozTextStyles.caption(isArabic: false).copyWith(color: DozColors.textSecondary)),
    ]);
  }
}
