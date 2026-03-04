import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Large bid input widget with +/- buttons.
class BidInput extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final double step;
  final ValueChanged<double> onChanged;

  const BidInput({super.key, required this.value, required this.minValue, required this.maxValue, this.step = 0.25, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: DozColors.cardDark, borderRadius: BorderRadius.circular(16), border: Border.all(color: DozColors.primaryGreen.withOpacity(0.4))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _controlButton(icon: Icons.remove, onPressed: value > minValue ? () => onChanged((value - step).clamp(minValue, maxValue)) : null),
          Column(
            children: [
              Text(value.toStringAsFixed(3), style: DozTextStyles.priceHero(color: DozColors.primaryGreen).copyWith(fontSize: 40)),
              Text(AppConstants.defaultCurrency, style: DozTextStyles.labelMedium(isArabic: isAr).copyWith(color: DozColors.textMuted)),
            ],
          ),
          _controlButton(icon: Icons.add, onPressed: value < maxValue ? () => onChanged((value + step).clamp(minValue, maxValue)) : null),
        ],
      ),
    );
  }

  Widget _controlButton({required IconData icon, required VoidCallback? onPressed}) {
    return Material(
      color: onPressed != null ? DozColors.primaryGreen.withOpacity(0.15) : DozColors.borderDark,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(width: 44, height: 44, child: Icon(icon, color: onPressed != null ? DozColors.primaryGreen : DozColors.textDisabled, size: 24)),
      ),
    );
  }
}
