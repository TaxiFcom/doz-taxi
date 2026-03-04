/// Input validators for DOZ Taxi forms.
abstract class DozValidators {
  static String? phone(String? value, {String lang = 'ar'}) {
    if (value == null || value.isEmpty) {
      return lang == 'ar' ? '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641 \u0645\u0637\u0644\u0648\u0628' : 'Phone number is required';
    }
    final digits = value.replaceAll(RegExp(r'\s|-'), '');
    final cleaned = digits.startsWith('0') ? digits.substring(1) : digits;
    if (!RegExp(r'^7[789][0-9]{7}$').hasMatch(cleaned)) {
      return lang == 'ar' ? '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641 \u063a\u064a\u0631 \u0635\u062d\u064a\u062d' : 'Invalid phone number';
    }
    return null;
  }

  static String? phoneGeneral(String? value, {String lang = 'ar'}) {
    if (value == null || value.isEmpty) {
      return lang == 'ar' ? '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641 \u0645\u0637\u0644\u0648\u0628' : 'Phone number is required';
    }
    final digits = value.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    if (digits.length < 7 || digits.length > 15) {
      return lang == 'ar' ? '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641 \u063a\u064a\u0631 \u0635\u062d\u064a\u062d' : 'Invalid phone number';
    }
    return null;
  }

  static String? email(String? value, {String lang = 'ar'}) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!regex.hasMatch(value.trim())) {
      return lang == 'ar' ? '\u0627\u0644\u0628\u0631\u064a\u062f \u0627\u0644\u0625\u0644\u0643\u062a\u0631\u0648\u0646\u064a \u063a\u064a\u0631 \u0635\u062d\u064a\u062d' : 'Invalid email address';
    }
    return null;
  }

  static String? name(String? value, {String lang = 'ar'}) {
    if (value == null || value.trim().isEmpty) {
      return lang == 'ar' ? '\u0627\u0644\u0627\u0633\u0645 \u0645\u0637\u0644\u0648\u0628' : 'Name is required';
    }
    if (value.trim().length < 2) {
      return lang == 'ar' ? '\u0627\u0644\u0627\u0633\u0645 \u0642\u0635\u064a\u0631 \u062c\u062f\u0627\u064b' : 'Name is too short';
    }
    if (value.trim().length > 60) {
      return lang == 'ar' ? '\u0627\u0644\u0627\u0633\u0645 \u0637\u0648\u064a\u0644 \u062c\u062f\u0627\u064b' : 'Name is too long';
    }
    return null;
  }

  static String? price(
    String? value, {
    double min = 0.5,
    double max = 500.0,
    String lang = 'ar',
  }) {
    if (value == null || value.isEmpty) {
      return lang == 'ar' ? '\u0627\u0644\u0633\u0639\u0631 \u0645\u0637\u0644\u0648\u0628' : 'Price is required';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      return lang == 'ar' ? '\u0627\u0644\u0633\u0639\u0631 \u063a\u064a\u0631 \u0635\u062d\u064a\u062d' : 'Invalid price';
    }
    if (parsed < min) {
      return lang == 'ar' ? '\u0627\u0644\u0633\u0639\u0631 \u064a\u062c\u0628 \u0623\u0646 \u064a\u0643\u0648\u0646 $min \u062f\u064a\u0646\u0627\u0631 \u0639\u0644\u0649 \u0627\u0644\u0623\u0642\u0644' : 'Minimum price is $min JOD';
    }
    if (parsed > max) {
      return lang == 'ar' ? '\u0627\u0644\u0633\u0639\u0631 \u064a\u062c\u0628 \u0623\u0646 \u0644\u0627 \u064a\u062a\u062c\u0627\u0648\u0632 $max \u062f\u064a\u0646\u0627\u0631' : 'Maximum price is $max JOD';
    }
    return null;
  }

  static String? required_(
    String? value, {
    String fieldName = '\u0627\u0644\u062d\u0642\u0644',
    String lang = 'ar',
  }) {
    if (value == null || value.trim().isEmpty) {
      return lang == 'ar' ? '$fieldName \u0645\u0637\u0644\u0648\u0628' : '$fieldName is required';
    }
    return null;
  }

  static String? otp(String? value, {String lang = 'ar'}) {
    if (value == null || value.isEmpty) {
      return lang == 'ar' ? '\u0631\u0645\u0632 \u0627\u0644\u062a\u062d\u0642\u0642 \u0645\u0637\u0644\u0648\u0628' : 'OTP is required';
    }
    if (!RegExp(r'^\d{4,6}$').hasMatch(value)) {
      return lang == 'ar' ? '\u0631\u0645\u0632 \u0627\u0644\u062a\u062d\u0642\u0642 \u063a\u064a\u0631 \u0635\u062d\u064a\u062d' : 'Invalid OTP';
    }
    return null;
  }

  static String? licenseNumber(String? value, {String lang = 'ar'}) {
    if (value == null || value.trim().isEmpty) {
      return lang == 'ar' ? '\u0631\u0642\u0645 \u0627\u0644\u0631\u062e\u0635\u0629 \u0645\u0637\u0644\u0648\u0628' : 'License number is required';
    }
    if (value.trim().length < 5) {
      return lang == 'ar' ? '\u0631\u0642\u0645 \u0627\u0644\u0631\u062e\u0635\u0629 \u063a\u064a\u0631 \u0635\u062d\u064a\u062d' : 'Invalid license number';
    }
    return null;
  }

  static String? amount(
    String? value, {
    double min = 1.0,
    String lang = 'ar',
  }) {
    if (value == null || value.isEmpty) {
      return lang == 'ar' ? '\u0627\u0644\u0645\u0628\u0644\u063a \u0645\u0637\u0644\u0648\u0628' : 'Amount is required';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return lang == 'ar' ? '\u0627\u0644\u0645\u0628\u0644\u063a \u063a\u064a\u0631 \u0635\u062d\u064a\u062d' : 'Invalid amount';
    }
    if (parsed < min) {
      return lang == 'ar' ? '\u0627\u0644\u062d\u062f \u0627\u0644\u0623\u062f\u0646\u0649 $min' : 'Minimum amount is $min';
    }
    return null;
  }
}
