import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doz_colors.dart';

/// DOZ text style definitions.
/// Arabic: Tajawal | English: Inter
abstract class DozTextStyles {
  static TextStyle _arabic({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.tajawal(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _english({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle heroTitle({bool isArabic = true, Color? color}) =>
      isArabic
          ? _arabic(size: 36, weight: FontWeight.w800, color: color ?? DozColors.textPrimary, height: 1.2)
          : _english(size: 36, weight: FontWeight.w800, color: color ?? DozColors.textPrimary, height: 1.2);

  static TextStyle pageTitle({bool isArabic = true, Color? color}) =>
      isArabic
          ? _arabic(size: 24, weight: FontWeight.w700, color: color ?? DozColors.textPrimary, height: 1.3)
          : _english(size: 24, weight: FontWeight.w700, color: color ?? DozColors.textPrimary, height: 1.3);

  static TextStyle sectionTitle({bool isArabic = true, Color? color}) =>
      isArabic
          ? _arabic(size: 18, weight: FontWeight.w600, color: color ?? DozColors.textPrimary, height: 1.4)
          : _english(size: 18, weight: FontWeight.w600, color: color ?? DozColors.textPrimary, height: 1.4);

  static TextStyle bodyLarge({bool isArabic = true, Color? color}) =>
      isArabic
          ? _arabic(size: 16, weight: FontWeight.w400, color: color ?? DozColors.textSecondary, height: 1.6)
          : _english(size: 16, weight: FontWeight.w400, color: color ?? DozColors.textSecondary, height: 1.6);

  static TextStyle bodyMedium({bool isArabic = true, Color? color}) =>
      isArabic
          ? _arabic(size: 14, weight: FontWeight.w400, color: color ?? DozColors.textSecondary, height: 1.5)
          : _english(size: 14, weight: FontWeight.w400, color: color ?? DozColors.textSecondary, height: 1.5);

  static TextStyle bodySmall({bool isArabic = true, Color? color}) =>
      isArabic
          ? _arabic(size: 12, weight: FontWeight.w400, color: color ?? DozColors.textMuted, height: 1.5)
          : _english(size: 12, weight: FontWeight.w400, color: color ?? DozColors.textMuted, height: 1.5);

  static TextStyle caption({bool isArabic = true, Color? color}) =>
      isArabic
          ? _arabic(size: 11, weight: FontWeight.w400, color: color ?? DozColors.textMuted, height: 1.4)
          : _english(size: 11, weight: FontWeight.w400, color: color ?? DozColors.textMuted, height: 1.4);

  static TextStyle buttonText({bool isArabic = true, Color? color}) =>
      isArabic
          ? _arabic(size: 16, weight: FontWeight.w700, color: color ?? DozColors.primaryDark, letterSpacing: 0.5)
          : _english(size: 16, weight: FontWeight.w600, color: color ?? DozColors.primaryDark, letterSpacing: 0.3);

  static TextStyle buttonSmall({bool isArabic = true, Color? color}) =>
      isArabic
          ? _arabic(size: 14, weight: FontWeight.w600, color: color ?? DozColors.primaryDark)
          : _english(size: 14, weight: FontWeight.w500, color: color ?? DozColors.primaryDark);

  static TextStyle labelLarge({bool isArabic = true, Color? color}) =>
      isArabic
          ? _arabic(size: 14, weight: FontWeight.w600, color: color ?? DozColors.textSecondary)
          : _english(size: 14, weight: FontWeight.w600, color: color ?? DozColors.textSecondary);

  static TextStyle labelMedium({bool isArabic = true, Color? color}) =>
      isArabic
          ? _arabic(size: 12, weight: FontWeight.w500, color: color ?? DozColors.textMuted)
          : _english(size: 12, weight: FontWeight.w500, color: color ?? DozColors.textMuted);

  static TextStyle priceHero({Color? color}) => _english(
        size: 48,
        weight: FontWeight.w700,
        color: color ?? DozColors.primaryGreen,
        letterSpacing: -1,
      );

  static TextStyle priceLarge({Color? color}) => _english(
        size: 28,
        weight: FontWeight.w700,
        color: color ?? DozColors.primaryGreen,
      );

  static TextStyle priceMedium({Color? color}) => _english(
        size: 20,
        weight: FontWeight.w600,
        color: color ?? DozColors.textPrimary,
      );

  static TextStyle mono({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) =>
      GoogleFonts.robotoMono(
        fontSize: size,
        fontWeight: weight,
        color: color ?? DozColors.textSecondary,
      );
}
