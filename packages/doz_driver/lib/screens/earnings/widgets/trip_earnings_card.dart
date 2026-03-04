import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Card showing earnings from a single completed trip.
class TripEarningsCard extends StatelessWidget {
  final RideModel ride;
  final bool isAr;

  const TripEarningsCard({
    super.key,
    required this.ride,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final fare = ride.finalPrice ?? ride.suggestedPrice;
    final net = fare * (1 - AppConstants.commissionRate);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DozColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DozColors.borderDark),
      ),
      child: Row(
        children: [
          // Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DozFormatters.time(ride.createdAt,
                    lang: isAr ? 'ar' : 'en'),
                style: DozTextStyles.labelMedium(isArabic: isAr)
                    .copyWith(color: DozColors.textPrimary),
              ),
              Text(
                DozFormatters.relativeDate(ride.createdAt,
                    lang: isAr ? 'ar' : 'en'),
                style: DozTextStyles.caption(isArabic: isAr),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Route
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.pickupAddress,
                  style: DozTextStyles.caption(isArabic: isAr)
                      .copyWith(color: DozColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  ride.dropoffAddress,
                  style: DozTextStyles.caption(isArabic: isAr)
                      .copyWith(color: DozColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Earnings
          Text(
            '+${DozFormatters.currency(net)}',
            style: DozTextStyles.bodyMedium(isArabic: false)
                .copyWith(
              color: DozColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
