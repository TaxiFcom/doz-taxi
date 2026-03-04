import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doz_colors.dart';
import 'doz_text_styles.dart';

/// Full ThemeData configuration for DOZ apps.
abstract class DozTheme {
  // ── Dark Theme (Rider & Driver apps) ─────────────────────────────────────────────

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: DozColors.primaryGreen,
        onPrimary: DozColors.primaryDark,
        secondary: DozColors.primaryGreen,
        onSecondary: DozColors.primaryDark,
        surface: DozColors.surfaceDark,
        onSurface: DozColors.textPrimary,
        error: DozColors.error,
        onError: Colors.white,
        outline: DozColors.borderDark,
        shadow: Colors.black,
        scrim: DozColors.scrim,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: DozColors.primaryDark,
      cardColor: DozColors.cardDark,
      dividerColor: DozColors.borderDark,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: DozColors.primaryDark,
        foregroundColor: DozColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: DozColors.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: DozColors.textPrimary,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: DozColors.textPrimary,
          size: 24,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: DozColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: DozColors.borderDark, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DozColors.primaryGreen,
          foregroundColor: DozColors.primaryDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 16),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Outlined Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DozColors.primaryGreen,
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 16),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(
              color: DozColors.primaryGreen, width: 1.5),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DozColors.primaryGreen,
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DozColors.cardDark,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: DozColors.borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: DozColors.borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: DozColors.primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: DozColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: DozColors.error, width: 1.5),
        ),
        labelStyle: GoogleFonts.tajawal(
          color: DozColors.textMuted,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.tajawal(
          color: DozColors.textDisabled,
          fontSize: 14,
        ),
        errorStyle: GoogleFonts.tajawal(
          color: DozColors.error,
          fontSize: 12,
        ),
        prefixIconColor: DozColors.textMuted,
        suffixIconColor: DozColors.textMuted,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DozColors.navDark,
        selectedItemColor: DozColors.primaryGreen,
        unselectedItemColor: DozColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DozColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: DozColors.borderDark,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: DozColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: DozColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.tajawal(
          fontSize: 14,
          color: DozColors.textSecondary,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DozColors.cardDark,
        contentTextStyle: GoogleFonts.tajawal(
          color: DozColors.textPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DozColors.primaryGreen;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(DozColors.primaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: DozColors.borderDark, width: 1.5),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DozColors.primaryDark;
          }
          return DozColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DozColors.primaryGreen;
          }
          return DozColors.borderDark;
        }),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: DozColors.primaryGreen,
        linearTrackColor: DozColors.borderDark,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: DozColors.borderDark,
        thickness: 1,
        space: 1,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: DozColors.textPrimary,
        ),
        subtitleTextStyle: GoogleFonts.tajawal(
          fontSize: 13,
          color: DozColors.textMuted,
        ),
        iconColor: DozColors.textMuted,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: DozColors.cardDark,
        selectedColor: DozColors.primaryGreenSurface,
        labelStyle: GoogleFonts.tajawal(
          fontSize: 13,
          color: DozColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side:
              const BorderSide(color: DozColors.borderDark, width: 1),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),
      ),

      // Text theme (base)
      textTheme: GoogleFonts.tajawalTextTheme(
        const TextTheme(
          displayLarge:
              TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
          displayMedium:
              TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
          displaySmall:
              TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
          headlineLarge:
              TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          headlineMedium:
              TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          headlineSmall:
              TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          titleLarge:
              TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          titleMedium:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          titleSmall:
              TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          bodyLarge:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium:
              TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          bodySmall:
              TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          labelLarge:
              TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          labelMedium:
              TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          labelSmall:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ).apply(
        bodyColor: DozColors.textSecondary,
        displayColor: DozColors.textPrimary,
      ),
    );
  }

  // ── Light Theme (Admin Dashboard) ─────────────────────────────────────────────

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: DozColors.primaryGreen,
        onPrimary: Colors.white,
        secondary: DozColors.primaryGreen,
        onSecondary: Colors.white,
        surface: DozColors.surfaceLight,
        onSurface: DozColors.textPrimaryLight,
        error: DozColors.error,
        onError: Colors.white,
        outline: DozColors.borderLight,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: DozColors.backgroundLight,
      cardColor: DozColors.cardLight,
      dividerColor: DozColors.borderLight,

      appBarTheme: AppBarTheme(
        backgroundColor: DozColors.surfaceLight,
        foregroundColor: DozColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: DozColors.borderLight,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: DozColors.textPrimaryLight,
        ),
      ),

      cardTheme: CardThemeData(
        color: DozColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
              color: DozColors.borderLight, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DozColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 14),
          minimumSize: const Size(120, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DozColors.backgroundLight,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: DozColors.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: DozColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: DozColors.primaryGreen, width: 1.5),
        ),
      ),

      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: DozColors.textSecondaryLight,
        displayColor: DozColors.textPrimaryLight,
      ),
    );
  }
}
