import 'package:flutter/material.dart';

/// DOZ color palette.
/// Primary: Saudi Green (#1A6B3C)
/// Accent: Warm Gold (#F4A435)
/// Background: Near-black (#0D0D0D)
abstract class DozColors {
  static const Color primaryGreen = Color(0xFF1A6B3C);
  static const Color primaryLight = Color(0xFF2A9156);
  static const Color primaryDark = Color(0xFF0F4425);
  static const Color primaryGlow = Color(0xFF00FF88);

  static const Color accentGold = Color(0xFFF4A435);
  static const Color accentGoldLight = Color(0xFFFFC166);
  static const Color accentGoldDark = Color(0xFFB87820);

  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF242424);
  static const Color surfaceHighlight = Color(0xFF2E2E2E);

  static const Color textPrimary = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF707070);
  static const Color textInverse = Color(0xFF0D0D0D);

  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  static const Color statusPending = Color(0xFFF39C12);
  static const Color statusBidding = Color(0xFF3498DB);
  static const Color statusAccepted = Color(0xFF2ECC71);
  static const Color statusInProgress = Color(0xFF1A6B3C);
  static const Color statusCompleted = Color(0xFF27AE60);
  static const Color statusCancelled = Color(0xFFE74C3C);

  static const Color mapRoute = Color(0xFF1A6B3C);
  static const Color mapPickup = Color(0xFF2ECC71);
  static const Color mapDropoff = Color(0xFFE74C3C);
  static const Color mapDriver = Color(0xFFF4A435);

  static const Color border = Color(0xFF2E2E2E);
  static const Color divider = Color(0xFF1F1F1F);

  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x33000000);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, primaryLight],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, surface],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGold, accentGoldDark],
  );

  static const Color transparent = Colors.transparent;
}
