import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../theme/doz_colors.dart';

/// Extension methods on [String].
extension DozStringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? w : w.capitalize)
      .join(' ');

  bool get isValidPhone =>
      RegExp(r'^\+?[\d\s\-\(\)]{7,15}$').hasMatch(this);

  bool get isValidEmail => RegExp(
        r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(this);

  bool get isArabic =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(this);

  String truncate([int maxLength = 50]) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}\u2026';
  }

  String get stripped => replaceAll(RegExp(r'\s'), '');

  double? toDoubleOrNull() =>
      double.tryParse(replaceAll(',', '.'));
}

/// Extension methods on [DateTime].
extension DozDateTimeExtensions on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year &&
        month == now.month &&
        day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  DateTime get startOfDay =>
      DateTime(year, month, day, 0, 0, 0);

  DateTime get endOfDay =>
      DateTime(year, month, day, 23, 59, 59, 999);

  DateTime get startOfWeek {
    final weekday = this.weekday;
    final daysToSaturday = (weekday + 1) % 7;
    return subtract(Duration(days: daysToSaturday)).startOfDay;
  }

  DateTime get startOfMonth => DateTime(year, month, 1);
}

/// Extension methods on [BuildContext].
extension DozContextExtensions on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  double get keyboardHeight =>
      MediaQuery.of(this).viewInsets.bottom;

  bool get isKeyboardOpen => keyboardHeight > 0;

  void dismissKeyboard() =>
      FocusScope.of(this).unfocus();

  bool get isArabic =>
      Localizations.localeOf(this).languageCode == 'ar';

  bool get isTablet => screenWidth >= 600;
  bool get isDesktop => screenWidth >= 1024;

  ThemeData get theme => Theme.of(this);

  void showSnackBar(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? DozColors.error : DozColors.success,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<T?> pushReplacement<T>(Widget page) =>
      Navigator.pushReplacement<T, void>(
        this,
        MaterialPageRoute(builder: (_) => page),
      );

  Future<T?> push<T>(Widget page) => Navigator.push<T>(
        this,
        MaterialPageRoute(builder: (_) => page),
      );

  void pop<T>([T? result]) => Navigator.pop<T>(this, result);
}

/// Extension methods on [RideStatus].
extension RideStatusExtensions on RideStatus {
  Color get color {
    switch (this) {
      case RideStatus.pending:
        return DozColors.statusPending;
      case RideStatus.bidding:
        return DozColors.statusBidding;
      case RideStatus.accepted:
        return DozColors.statusAccepted;
      case RideStatus.driverArriving:
        return DozColors.statusInProgress;
      case RideStatus.inProgress:
        return DozColors.statusInProgress;
      case RideStatus.completed:
        return DozColors.statusCompleted;
      case RideStatus.cancelled:
        return DozColors.statusCancelled;
    }
  }

  bool get isTerminal =>
      this == RideStatus.completed || this == RideStatus.cancelled;

  bool get isActive => !isTerminal;
}

/// Extension on [num] for spacing widgets.
extension NumSpacing on num {
  SizedBox get h => SizedBox(height: toDouble());
  SizedBox get w => SizedBox(width: toDouble());
}
