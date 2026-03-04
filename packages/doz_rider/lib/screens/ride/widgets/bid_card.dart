import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Bid card showing driver offer details for the bids screen.
class BidCard extends StatelessWidget {
  final BidModel bid;
  final double suggestedPrice;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const BidCard({
    super.key,
    required this.bid,
    required this.suggestedPrice,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    final driver = bid.driver;
    final name = driver?.user?.name ?? (isArabic ? 'سائق' : 'Driver');
    final isCheaper = bid.amount <= suggestedPrice;
    final diff = (bid.amount - suggestedPrice).abs();

    return DozCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Driver avatar
              DozAvatar(
                imageUrl: driver?.user?.avatarUrl,
                name: name,
                size: 48,
                badge: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: DozColors.success,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Driver info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: DozTextStyles.bodyMedium(isArabic: isArabic)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (driver != null) ...[
                          DozRatingStars(rating: driver.rating, starSize: 12),
                          const SizedBox(width: 4),
                          Text(
                            DozFormatters.rating(driver.rating),
                            style: DozTextStyles.caption(isArabic: false),
                          ),
                        ],
                      ],
                    ),
                    if (driver != null)
                      Text(
                        '${driver.vehicleModel} · ${driver.plateNumber}',
                        style: DozTextStyles.caption(isArabic: isArabic)
                            .copyWith(color: DozColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Bid amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  DozPriceTag(
                    amount: bid.amount,
                    color: isCheaper ? DozColors.success : DozColors.error,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isCheaper ? DozColors.success : DozColors.error)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isCheaper
                          ? '${isArabic ? 'أقل بـ ' : '-'}${diff.toStringAsFixed(3)} JOD'
                          : '${isArabic ? 'أعلى بـ ' : '+'}${diff.toStringAsFixed(3)} JOD',
                      style: DozTextStyles.caption(
                        isArabic: isArabic,
                        color:
                            isCheaper ? DozColors.success : DozColors.error,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Accept / Reject buttons
          Row(
            children: [
              Expanded(
                child: DozButton(
                  label: isArabic ? 'رفض' : 'Reject',
                  onPressed: onReject,
                  variant: DozButtonVariant.outlined,
                  height: 40,
                  borderRadius: 10,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: DozButton(
                  label: isArabic ? 'قبول العرض' : 'Accept Bid',
                  onPressed: onAccept,
                  height: 40,
                  borderRadius: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
