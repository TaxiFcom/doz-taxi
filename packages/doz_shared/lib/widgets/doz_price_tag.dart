import 'package:flutter/material.dart';
import '../theme/doz_colors.dart';
import '../theme/doz_text_styles.dart';
import '../utils/formatters.dart';

/// Formatted price display tag.
class DozPriceTag extends StatelessWidget {
  final double amount;
  final String currency;
  final TextStyle? style;
  final TextStyle? currencyStyle;
  final Color? color;
  final bool showCurrencyCode;
  final CrossAxisAlignment alignment;

  const DozPriceTag({
    super.key,
    required this.amount,
    this.currency = 'JOD',
    this.style,
    this.currencyStyle,
    this.color,
    this.showCurrencyCode = true,
    this.alignment = CrossAxisAlignment.baseline,
  });

  @override
  Widget build(BuildContext context) {
    final priceColor = color ?? DozColors.primaryGreen;
    final formatted = DozFormatters.currency(amount, currency: '');

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        Text(
          formatted,
          style: style ?? DozTextStyles.priceLarge(color: priceColor),
        ),
        if (showCurrencyCode) ...[
          const SizedBox(width: 4),
          Text(
            currency,
            style: currencyStyle ??
                DozTextStyles.bodySmall(color: priceColor.withOpacity(0.7)),
          ),
        ],
      ],
    );
  }
}

/// Editable price input.
class DozPriceInput extends StatefulWidget {
  final double initialValue;
  final double minValue;
  final double maxValue;
  final double step;
  final String currency;
  final ValueChanged<double> onChanged;

  const DozPriceInput({
    super.key,
    required this.initialValue,
    this.minValue = 1.0,
    this.maxValue = 500.0,
    this.step = 0.5,
    this.currency = 'JOD',
    required this.onChanged,
  });

  @override
  State<DozPriceInput> createState() => _DozPriceInputState();
}

class _DozPriceInputState extends State<DozPriceInput> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _increment() {
    if (_value + widget.step <= widget.maxValue) {
      setState(() => _value += widget.step);
      widget.onChanged(_value);
    }
  }

  void _decrement() {
    if (_value - widget.step >= widget.minValue) {
      setState(() => _value -= widget.step);
      widget.onChanged(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(icon: Icons.remove_rounded, onTap: _decrement, enabled: _value > widget.minValue),
        const SizedBox(width: 24),
        Column(
          children: [
            Text(DozFormatters.currency(_value, currency: ''), style: DozTextStyles.priceHero()),
            Text(widget.currency, style: DozTextStyles.bodySmall(color: DozColors.textMuted)),
          ],
        ),
        const SizedBox(width: 24),
        _ControlButton(icon: Icons.add_rounded, onTap: _increment, enabled: _value < widget.maxValue),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _ControlButton({required this.icon, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.3,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DozColors.surface,
            border: Border.all(color: DozColors.border, width: 1),
          ),
          child: Icon(icon, color: DozColors.textPrimary, size: 22),
        ),
      ),
    );
  }
}
