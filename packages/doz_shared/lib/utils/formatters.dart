import 'package:intl/intl.dart';

/// Formatting utilities for dates, times, currency, and distances.
abstract class DozFormatters {
  static String currency(
    double amount, {
    String currency = 'JOD',
    int decimalDigits = 3,
    String locale = 'ar',
  }) {
    final formatter = NumberFormat.currency(
      locale: locale == 'ar' ? 'ar_JO' : 'en_US',
      symbol: '',
      decimalDigits: decimalDigits,
    );
    final formatted = formatter.format(amount).trim();
    return currency.isEmpty ? formatted : '$formatted $currency';
  }

  static String compactNumber(num value, {String locale = 'en'}) {
    return NumberFormat.compact(locale: locale).format(value);
  }

  static String distance(double km, {String lang = 'ar'}) {
    if (km < 1.0) {
      final meters = (km * 1000).round();
      return lang == 'ar' ? '$meters \u0645' : '${meters}m';
    }
    final formatted = km.toStringAsFixed(1);
    return lang == 'ar' ? '$formatted \u0643\u0645' : '${formatted}km';
  }

  static String duration(int minutes, {String lang = 'ar'}) {
    if (minutes < 60) {
      return lang == 'ar' ? '$minutes \u062f\u0642\u064a\u0642\u0629' : '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return lang == 'ar' ? '$hours \u0633\u0627\u0639\u0629' : '${hours}h';
    }
    return lang == 'ar' ? '$hours \u0633 $mins \u062f' : '${hours}h ${mins}m';
  }

  static String date(DateTime date, {String lang = 'ar'}) {
    final locale = lang == 'ar' ? 'ar' : 'en';
    return DateFormat.yMMMMd(locale).format(date);
  }

  static String dateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String time(DateTime time, {String lang = 'ar'}) {
    final locale = lang == 'ar' ? 'ar' : 'en';
    return DateFormat.jm(locale).format(time);
  }

  static String relativeDate(DateTime date, {String lang = 'ar'}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateDay).inDays;

    if (diff == 0) return lang == 'ar' ? '\u0627\u0644\u064a\u0648\u0645' : 'Today';
    if (diff == 1) return lang == 'ar' ? '\u0623\u0645\u0633' : 'Yesterday';
    if (diff < 7) {
      final locale = lang == 'ar' ? 'ar' : 'en';
      return DateFormat.EEEE(locale).format(date);
    }
    return dateShort(date);
  }

  static String timeAgo(DateTime date, {String lang = 'ar'}) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return lang == 'ar' ? '\u0627\u0644\u0622\u0646' : 'Just now';
    }
    if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      return lang == 'ar' ? '\u0645\u0646\u0630 $mins \u062f\u0642\u064a\u0642\u0629' : '${mins}m ago';
    }
    if (diff.inHours < 24) {
      final hrs = diff.inHours;
      return lang == 'ar' ? '\u0645\u0646\u0630 $hrs \u0633\u0627\u0639\u0629' : '${hrs}h ago';
    }
    return relativeDate(date, lang: lang);
  }

  static String phone(String phone, {String prefix = '+962'}) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10 && digits.startsWith('0')) {
      return '$prefix ${digits.substring(1, 3)} ${digits.substring(3, 7)} ${digits.substring(7)}';
    }
    return phone;
  }

  static String rating(double value) =>
      value.toStringAsFixed(1);

  static String percentage(double value, {int digits = 1}) =>
      '${value.toStringAsFixed(digits)}%';

  static String plateNumber(String plate) =>
      plate.toUpperCase().replaceAll('-', ' ');
}
