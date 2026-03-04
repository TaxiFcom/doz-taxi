import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// "Where to?" search card that opens the location search screen.
class SearchBarWidget extends StatelessWidget {
  final VoidCallback onTap;

  const SearchBarWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: DozColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DozColors.borderDark),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: DozColors.primaryGreenSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: DozColors.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isArabic ? 'إلى أين؟' : 'Where to?',
              style: DozTextStyles.bodyLarge(
                isArabic: isArabic,
                color: DozColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
