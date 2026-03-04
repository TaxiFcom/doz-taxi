import 'package:flutter/material.dart';
import '../theme/doz_colors.dart';
import '../theme/doz_text_styles.dart';

/// DOZ empty state widget.
class DozEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;
  final Color? iconColor;

  const DozEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconSize = 72,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize * 1.6,
              height: iconSize * 1.6,
              decoration: BoxDecoration(
                color: DozColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: DozColors.border, width: 1),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor ?? DozColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: DozTextStyles.sectionTitle(isArabic: isArabic),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: DozTextStyles.bodyMedium(isArabic: isArabic),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// DOZ error state widget.
class DozErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const DozErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return DozEmptyState(
      icon: Icons.error_outline_rounded,
      iconColor: DozColors.error,
      title: '\u062d\u062f\u062b \u062e\u0637\u0623 / Error',
      subtitle: message,
      actionLabel: onRetry != null
          ? (retryLabel ?? '\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629 / Retry')
          : null,
      onAction: onRetry,
    );
  }
}
