import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../theme/doz_colors.dart';
import '../theme/doz_text_styles.dart';
import '../l10n/app_localizations.dart';

/// Colored status badge for ride, bid, and other statuses.
class DozStatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool dot;

  const DozStatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.dot = false,
  });

  factory DozStatusBadge.ride(
    RideStatus status, {
    Key? key,
    required BuildContext context,
  }) {
    final l10n = AppLocalizations.of(context);
    final (label, color) = _rideStatusInfo(status, l10n);
    return DozStatusBadge(
      key: key,
      label: label,
      backgroundColor: color.withOpacity(0.15),
      textColor: color,
    );
  }

  factory DozStatusBadge.bid(
    BidStatus status, {
    Key? key,
    required BuildContext context,
  }) {
    final l10n = AppLocalizations.of(context);
    final (label, color) = _bidStatusInfo(status, l10n);
    return DozStatusBadge(
      key: key,
      label: label,
      backgroundColor: color.withOpacity(0.15),
      textColor: color,
    );
  }

  static (String, Color) _rideStatusInfo(RideStatus status, AppLocalizations l10n) {
    switch (status) {
      case RideStatus.pending:
        return (l10n.t('statusPending'), DozColors.statusPending);
      case RideStatus.bidding:
        return (l10n.t('statusBidding'), DozColors.statusBidding);
      case RideStatus.accepted:
        return (l10n.t('statusAccepted'), DozColors.statusAccepted);
      case RideStatus.driverArriving:
        return (l10n.t('statusArriving'), DozColors.statusInProgress);
      case RideStatus.inProgress:
        return (l10n.t('statusInProgress'), DozColors.statusInProgress);
      case RideStatus.completed:
        return (l10n.t('statusCompleted'), DozColors.statusCompleted);
      case RideStatus.cancelled:
        return (l10n.t('statusCancelled'), DozColors.statusCancelled);
    }
  }

  static (String, Color) _bidStatusInfo(BidStatus status, AppLocalizations l10n) {
    switch (status) {
      case BidStatus.pending:
        return (l10n.t('statusPending'), DozColors.statusPending);
      case BidStatus.accepted:
        return (l10n.t('statusAccepted'), DozColors.statusAccepted);
      case BidStatus.rejected:
        return (l10n.t('statusCancelled'), DozColors.statusCancelled);
      case BidStatus.expired:
        return (l10n.t('bidExpired'), DozColors.textMuted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsetsDirectional.only(end: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: textColor,
              ),
            ),
          ],
          Text(
            label,
            style: DozTextStyles.caption(
              isArabic: isArabic,
              color: textColor,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
