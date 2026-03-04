import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Route summary showing pickup and dropoff addresses with connecting line.
class RouteSummary extends StatelessWidget {
  final String pickupAddress;
  final String dropoffAddress;
  final double? distanceKm;
  final int? durationMin;

  const RouteSummary({
    super.key,
    required this.pickupAddress,
    required this.dropoffAddress,
    this.distanceKm,
    this.durationMin,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;

    return DozCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Route points
          Row(
            children: [
              // Dot + line column
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: DozColors.mapPickup,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 28,
                    color: DozColors.borderDark,
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DozColors.mapDropoff,
                        width: 2,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: DozColors.mapDropoff,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Addresses
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickupAddress,
                      style: DozTextStyles.bodyMedium(isArabic: isArabic)
                          .copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      dropoffAddress,
                      style: DozTextStyles.bodyMedium(isArabic: isArabic)
                          .copyWith(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Distance + duration
          if (distanceKm != null || durationMin != null) ...[
            Divider(height: 16, color: DozColors.borderDark),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (distanceKm != null) ...[
                  const Icon(
                    Icons.straighten_rounded,
                    color: DozColors.textMuted,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DozFormatters.distance(distanceKm!,
                        lang: isArabic ? 'ar' : 'en'),
                    style: DozTextStyles.bodySmall(isArabic: isArabic),
                  ),
                ],
                if (distanceKm != null && durationMin != null)
                  const SizedBox(width: 16),
                if (durationMin != null) ...[
                  const Icon(
                    Icons.access_time_rounded,
                    color: DozColors.textMuted,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DozFormatters.duration(durationMin!,
                        lang: isArabic ? 'ar' : 'en'),
                    style: DozTextStyles.bodySmall(isArabic: isArabic),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
