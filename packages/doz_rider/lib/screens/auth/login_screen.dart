import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/app_router.dart';

/// Login screen — phone number input with country code picker.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _selectedCode = '+962';
  bool _loading = false;

  final List<Map<String, String>> _countryCodes = [
    {'code': '+962', 'flag': '🇯🇴', 'name': 'Jordan'},
    {'code': '+966', 'flag': '🇸🇦', 'name': 'Saudi Arabia'},
    {'code': '+971', 'flag': '🇦🇪', 'name': 'UAE'},
    {'code': '+965', 'flag': '🇰🇼', 'name': 'Kuwait'},
    {'code': '+974', 'flag': '🇶🇦', 'name': 'Qatar'},
    {'code': '+973', 'flag': '🇧🇭', 'name': 'Bahrain'},
    {'code': '+968', 'flag': '🇴🇲', 'name': 'Oman'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().requestOtp(
            phone: _phoneController.text.trim(),
            countryCode: _selectedCode,
          );
      if (!mounted) return;
      context.push(AppRoutes.otp, extra: {
        'phone': _phoneController.text.trim(),
        'countryCode': _selectedCode,
      });
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: DozColors.error,
      ),
    );
  }

  void _showCountryPicker() {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    showModalBottomSheet(
      context: context,
      backgroundColor: DozColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DozColors.borderDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                isArabic ? 'اختر رمز الدولة' : 'Select Country Code',
                style: DozTextStyles.sectionTitle(isArabic: isArabic),
              ),
            ),
            const SizedBox(height: 8),
            ..._countryCodes.map(
              (c) => ListTile(
                leading: Text(c['flag']!, style: const TextStyle(fontSize: 24)),
                title: Text(
                  '${c['name']} (${c['code']})',
                  style: DozTextStyles.bodyMedium(isArabic: isArabic),
                ),
                trailing: _selectedCode == c['code']
                    ? const Icon(Icons.check_rounded,
                        color: DozColors.primaryGreen)
                    : null,
                onTap: () {
                  setState(() => _selectedCode = c['code']!);
                  Navigator.pop(ctx);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      body: Container(
        decoration: const BoxDecoration(gradient: DozColors.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),

                  // Logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: DozColors.primaryGreen,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: DozColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'DOZ',
                          style: TextStyle(
                            color: DozColors.primaryDark,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    l10n.t('welcomeBack'),
                    style: DozTextStyles.pageTitle(isArabic: isArabic),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.t('enterPhone'),
                    style: DozTextStyles.bodyMedium(
                      isArabic: isArabic,
                      color: DozColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Phone input with country code
                  Text(
                    l10n.t('phone'),
                    style: DozTextStyles.labelLarge(isArabic: isArabic),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Country code picker
                      GestureDetector(
                        onTap: _showCountryPicker,
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: DozColors.cardDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: DozColors.borderDark),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedCode,
                                style: DozTextStyles.bodyLarge(
                                  isArabic: false,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: DozColors.textMuted,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Phone number field
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          style: DozTextStyles.bodyLarge(isArabic: false),
                          decoration: InputDecoration(
                            hintText:
                                isArabic ? '7XXXXXXXX' : '7XXXXXXXX',
                            fillColor: DozColors.cardDark,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: DozColors.borderDark),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: DozColors.borderDark),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: DozColors.primaryGreen, width: 1.5),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return isArabic
                                  ? 'أدخل رقم الهاتف'
                                  : 'Enter phone number';
                            }
                            if (v.length < 7) {
                              return isArabic
                                  ? 'رقم غير صحيح'
                                  : 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Send OTP button
                  DozButton(
                    label: l10n.t('sendOtp'),
                    onPressed: _loading ? null : _sendOtp,
                    loading: _loading,
                  ),

                  const SizedBox(height: 20),

                  // Login with email
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // TODO: implement email login
                      },
                      child: Text(
                        l10n.t('loginWithEmail'),
                        style: DozTextStyles.bodyMedium(
                          isArabic: isArabic,
                          color: DozColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Terms & Privacy
                  Text(
                    isArabic
                        ? 'بالمتابعة، أنت توافق على شروط الاستخدام وسياسة الخصوصية'
                        : 'By continuing, you agree to our Terms of Service and Privacy Policy',
                    style: DozTextStyles.caption(
                      isArabic: isArabic,
                      color: DozColors.textDisabled,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

