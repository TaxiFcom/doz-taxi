import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Driver info card for arriving/in-ride screens.
class DriverInfoCard extends StatelessWidget {
  final DriverModel driver;
  final String? eta;
  final bool showActions;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;

  const DriverInfoCard({
    super.key,
    required this.driver,
    this.eta,
    this.showActions = true,
    this.onCall,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    final name = driver.user?.name ?? '';

    return DozCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Driver avatar
              DozAvatar(
                imageUrl: driver.user?.avatarUrl,
                name: name,
                size: 52,
              ),
              const SizedBox(width: 12),

              // Driver info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: DozTextStyles.sectionTitle(isArabic: isArabic),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        DozRatingStars(
                          rating: driver.rating,
                          starSize: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DozFormatters.rating(driver.rating),
                          style: DozTextStyles.bodySmall(isArabic: false),
                        ),
                        Text(
                          ' · ',
                          style: DozTextStyles.bodySmall(isArabic: false),
                        ),
                        Text(
                          '${driver.totalRides} ${isArabic ? 'رحلة' : 'rides'}',
                          style: DozTextStyles.bodySmall(isArabic: isArabic),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ETA
              if (eta != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      eta!,
                      style: DozTextStyles.priceMedium()
                          .copyWith(color: DozColors.primaryGreen),
                    ),
                    Text(
                      isArabic ? 'وقت الوصول' : 'ETA',
                      style: DozTextStyles.caption(isArabic: isArabic),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Vehicle info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: DozColors.primaryDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.directions_car_rounded,
                  color: DozColors.textMuted,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${driver.vehicleModel} · ${driver.vehicleColor}',
                    style: DozTextStyles.bodySmall(isArabic: isArabic),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DozColors.cardDark,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: DozColors.borderDark),
                  ),
                  child: Text(
                    DozFormatters.plateNumber(driver.plateNumber),
                    style: DozTextStyles.mono(
                      size: 12,
                      weight: FontWeight.w600,
                      color: DozColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          if (showActions && (onCall != null || onMessage != null)) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onCall != null)
                  Expanded(
                    child: DozButton(
                      label: isArabic ? 'اتصل' : 'Call',
                      onPressed: onCall,
                      variant: DozButtonVariant.outlined,
                      height: 44,
                      prefixIcon: const Icon(Icons.phone_rounded, size: 18),
                    ),
                  ),
                if (onCall != null && onMessage != null)
                  const SizedBox(width: 8),
                if (onMessage != null)
                  Expanded(
                    child: DozButton(
                      label: isArabic ? 'رسالة' : 'Message',
                      onPressed: onMessage,
                      variant: DozButtonVariant.secondary,
                      height: 44,
                      prefixIcon:
                          const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
