import 'package:flutter/material.dart';
import '../theme/doz_colors.dart';

/// Clickable/display star rating widget.
class DozRatingStars extends StatelessWidget {
  final double rating;
  final int maxStars;
  final double starSize;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool interactive;
  final ValueChanged<int>? onRatingChanged;
  final MainAxisAlignment alignment;

  const DozRatingStars({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.starSize = 24,
    this.activeColor,
    this.inactiveColor,
    this.interactive = false,
    this.onRatingChanged,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? DozColors.warning;
    final inactive = inactiveColor ?? DozColors.border;

    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final starValue = index + 1;
        final isFilled = rating >= starValue;
        final isHalf = !isFilled && rating >= (starValue - 0.5);

        return GestureDetector(
          onTap: interactive ? () => onRatingChanged?.call(starValue) : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: starSize * 0.05),
            child: Icon(
              isHalf
                  ? Icons.star_half_rounded
                  : isFilled
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
              size: starSize,
              color: isFilled || isHalf ? active : inactive,
            ),
          ),
        );
      }),
    );
  }
}

/// Large interactive star picker for rating submissions.
class DozRatingPicker extends StatefulWidget {
  final ValueChanged<int> onRatingSelected;
  final int initialRating;
  final double starSize;

  const DozRatingPicker({
    super.key,
    required this.onRatingSelected,
    this.initialRating = 0,
    this.starSize = 48,
  });

  @override
  State<DozRatingPicker> createState() => _DozRatingPickerState();
}

class _DozRatingPickerState extends State<DozRatingPicker> {
  late int _selectedRating;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final star = index + 1;
        final isSelected = star <= _selectedRating;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedRating = star);
            widget.onRatingSelected(star);
          },
          child: AnimatedScale(
            scale: isSelected ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                size: widget.starSize,
                color: isSelected ? DozColors.warning : DozColors.textMuted,
              ),
            ),
          ),
        );
      }),
    );
  }
}
