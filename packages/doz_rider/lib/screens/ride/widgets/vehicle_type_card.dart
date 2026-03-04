import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Vehicle type card for horizontal scroll in confirm ride screen.
// VehicleTypeModel fields: id, nameAr, nameEn, icon, baseFare, perKm, perMin, minFare
class VehicleTypeCard extends StatelessWidget {
  final VehicleTypeModel vehicleType;
  final bool isSelected;
  final VoidCallback onTap;

  const VehicleTypeCard({
    super.key,
    required this.vehicleType,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'lux':
        return Icons.directions_car_filled_rounded;
      case 'premium':
        return Icons.local_taxi_rounded;
      case 'comfort':
        return Icons.directions_car_rounded;
      default:
        return Icons.hail_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    final name = isArabic ? vehicleType.nameAr : vehicleType.nameEn;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? DozColors.primaryGreenSurface
              : DozColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? DozColors.primaryGreen : DozColors.borderDark,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getVehicleIcon(vehicleType.id),
              color: isSelected
                  ? DozColors.primaryGreen
                  : DozColors.textMuted,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: DozTextStyles.caption(
                isArabic: isArabic,
                color: isSelected
                    ? DozColors.primaryGreen
                    : DozColors.textSecondary,
              ).copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${vehicleType.baseFare.toStringAsFixed(2)} JOD',
              style: DozTextStyles.caption(
                isArabic: false,
                color: isSelected
                    ? DozColors.primaryGreen
                    : DozColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '~${(vehicleType.baseFare * 2).round()} ${isArabic ? 'د' : 'min'}',
              style: DozTextStyles.caption(
                isArabic: isArabic,
                color: DozColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
