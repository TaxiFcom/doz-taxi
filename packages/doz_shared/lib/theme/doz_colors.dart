import 'package:flutter/material.dart';

/// DOZ brand color palette.
/// Primary: Lime green (#7ED321) on dark backgrounds.
/// Light mode is used for the admin dashboard.
abstract class DozColors {
  // ── Brand ─────────────────────────────────────────────────────────────────────

  /// Primary lime green — CTAs, active states, highlights.
  static const Color primaryGreen = Color(0xFF7ED321);
  static const Color primaryGreenDark = Color(0xFF6AB81B);
  static const Color primaryGreenLight = Color(0xFF9FE449);
  static const Color primaryGreenSurface = Color(0x1A7ED321); // 10% opacity

  // ── Dark Theme Surfaces ───────────────────────────────────────────────────────

  /// Main app background (darkest layer).
  static const Color primaryDark = Color(0xFF1A1A2E);

  /// Secondary surface (cards, sheets).
  static const Color surfaceDark = Color(0xFF16213E);

  /// Elevated card surface.
  static const Color cardDark = Color(0xFF1F2937);

  /// Bottom nav / persistent bars.
  static const Color navDark = Color(0xFF111827);

  /// Subtle dividers and borders in dark mode.
  static const Color borderDark = Color(0xFF374151);
  static const Color borderDarkSubtle = Color(0xFF1F2937);

  // ── Dark Theme Text ───────────────────────────────────────────────────────────

  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFFD1D5DB);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFF4B5563);

  // ── Light Theme Surfaces ──────────────────────────────────────────────────────

  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderLightSubtle = Color(0xFFF3F4F6);

  // ── Light Theme Text ──────────────────────────────────────────────────────────

  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF374151);
  static const Color textMutedLight = Color(0xFF6B7280);
  static const Color textDisabledLight = Color(0xFFD1D5DB);

  // ── Semantic ──────────────────────────────────────────────────────────────────

  /// Success green (different from brand green).
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);

  /// Warning amber.
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);

  /// Error red.
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);

  /// Info blue.
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1E3A5F);

  // ── Ride Status Colors ────────────────────────────────────────────────────────

  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusBidding = Color(0xFF8B5CF6);
  static const Color statusAccepted = Color(0xFF3B82F6);
  static const Color statusArriving = Color(0xFF06B6D4);
  static const Color statusInProgress = Color(0xFF7ED321);
  static const Color statusCompleted = Color(0xFF10B981);
  static const Color statusCancelled = Color(0xFFEF4444);

  // ── Map ───────────────────────────────────────────────────────────────────────

  static const Color mapPickup = Color(0xFF7ED321);
  static const Color mapDropoff = Color(0xFFEF4444);
  static const Color mapRoute = Color(0xFF7ED321);
  static const Color mapDriver = Color(0xFF3B82F6);

  // ── Overlay & Scrim ───────────────────────────────────────────────────────────

  static const Color scrim = Color(0x80000000);
  static const Color overlayLight = Color(0x0AFFFFFF);
  static const Color overlayDark = Color(0x0A000000);

  // ── Gradient ─────────────────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7ED321), Color(0xFF5DAD10)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F2937), Color(0xFF111827)],
  );

  // ── Aliases (for screens that use short/generic names) ──────────────────────
  
  static const Color primary = primaryGreen;
  static const Color primaryLight = primaryGreenLight;
  static const Color secondary = info;
  static const Color background = primaryDark;
  static const Color surface = surfaceDark;
  static const Color surfaceVariant = cardDark;
  static const Color surfaceElevated = Color(0xFF2D3748);
  static const Color border = borderDark;
  static const Color divider = borderDarkSubtle;
  static const Color textLight = textDisabled;
  static const Color overlay = overlayDark;
  static const Color gradientStart = primaryGreen;
  static const Color gradientEnd = primaryGreenDark;
  static const Color shimmerBase = surfaceDark;
  static const Color shimmerHighlight = cardDark;
  static const Color ratingStarActive = Color(0xFFFBBF24);
  static const Color ratingStarInactive = borderDark;
}
