import 'package:flutter/material.dart';
import '../theme/doz_colors.dart';
import '../theme/doz_text_styles.dart';

enum DozButtonVariant {
  primary,
  secondary,
  outlined,
  ghost,
  danger,
}

/// DOZ primary button component.
class DozButton extends StatelessWidget {
  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final DozButtonVariant variant;
  final bool loading;
  final bool fullWidth;
  final double? width;
  final double height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const DozButton({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.variant = DozButtonVariant.primary,
    this.loading = false,
    this.fullWidth = true,
    this.width,
    this.height = 56,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius = 16,
    this.padding,
  }) : assert(label != null || child != null,
            'Either label or child must be provided');

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';
    final isDisabled = onPressed == null || loading;

    Widget content = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(_getForegroundColor()),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixIcon != null) ...[
                prefixIcon!,
                const SizedBox(width: 8),
              ],
              child ??
                  Text(
                    label!,
                    style: DozTextStyles.buttonText(
                      isArabic: isArabic,
                      color: _getForegroundColor(),
                    ),
                  ),
              if (suffixIcon != null) ...[
                const SizedBox(width: 8),
                suffixIcon!,
              ],
            ],
          );

    return AnimatedOpacity(
      opacity: isDisabled ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        height: height,
        width: fullWidth ? double.infinity : width,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(borderRadius),
          border: variant == DozButtonVariant.outlined
              ? Border.all(color: DozColors.primaryGreen, width: 1.5)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.05),
            child: Padding(
              padding: padding ??
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case DozButtonVariant.primary:
        return DozColors.primaryGreen;
      case DozButtonVariant.secondary:
        return DozColors.surfaceElevated;
      case DozButtonVariant.outlined:
      case DozButtonVariant.ghost:
        return Colors.transparent;
      case DozButtonVariant.danger:
        return DozColors.error;
    }
  }

  Color _getForegroundColor() {
    switch (variant) {
      case DozButtonVariant.primary:
        return DozColors.primaryDark;
      case DozButtonVariant.outlined:
      case DozButtonVariant.ghost:
        return DozColors.primaryGreen;
      case DozButtonVariant.secondary:
        return DozColors.textPrimary;
      case DozButtonVariant.danger:
        return Colors.white;
    }
  }
}

/// Small icon button with DOZ styling.
class DozIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final String? tooltip;

  const DozIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 44,
    this.iconSize = 22,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: backgroundColor ?? DozColors.surfaceElevated,
        borderRadius: BorderRadius.circular(size / 2),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: IconTheme(
                data: IconThemeData(
                  color: iconColor ?? DozColors.textPrimary,
                  size: iconSize,
                ),
                child: icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
