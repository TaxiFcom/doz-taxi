import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  String _countryCode = AppConstants.jordanCountryCode;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.requestOtp(
      phone: _phoneController.text.trim(),
      countryCode: _countryCode,
    );

    if (success && mounted) {
      context.push(AppRoutes.otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                // Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: DozColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: DozColors.primaryGreen.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'D',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: DozColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Headline
                Center(
                  child: Text(
                    isAr ? 'DOZ سائق' : 'DOZ Driver',
                    style: DozTextStyles.pageTitle(isArabic: isAr),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    l.t('enterPhone'),
                    style: DozTextStyles.bodyMedium(
                        isArabic: isAr,
                        color: DozColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 48),
                // Country code + phone
                Text(
                  l.t('phone'),
                  style: DozTextStyles.labelLarge(isArabic: isAr),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Country code dropdown
                    GestureDetector(
                      onTap: () => _showCountryCodePicker(),
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
                              _countryCode,
                              style:
                                  DozTextStyles.bodyLarge(isArabic: false),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: DozColors.textMuted,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DozTextField(
                        controller: _phoneController,
                        hint: '7XXXXXXXX',
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l.t('required_');
                          }
                          if (v.trim().length < 7) {
                            return l.t('invalidPhone');
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Error message
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.errorMessage != null) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: DozColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: DozColors.error.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: DozColors.error,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  auth.errorMessage!,
                                  style: DozTextStyles.bodySmall(
                                    isArabic: isAr,
                                    color: DozColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                // Send OTP button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return DozButton(
                      label: l.t('sendOtp'),
                      loading: auth.isLoading,
                      onPressed: _sendOtp,
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Terms notice
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l.t('agreeToTerms'),
                      style: DozTextStyles.caption(
                        isArabic: isAr,
                        color: DozColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: DozColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        const codes = [
          ('+962', 'Jordan 🇯🇴'),
          ('+966', 'Saudi Arabia 🇸🇦'),
          ('+971', 'UAE 🇦🇪'),
          ('+965', 'Kuwait 🇰🇼'),
          ('+974', 'Qatar 🇶🇦'),
          ('+968', 'Oman 🇴🇲'),
          ('+973', 'Bahrain 🇧🇭'),
        ];
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DozColors.borderDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ...codes.map((c) => ListTile(
                    title: Text(
                      '${c.$2} (${c.$1})',
                      style: DozTextStyles.bodyMedium(),
                    ),
                    trailing: _countryCode == c.$1
                        ? const Icon(
                            Icons.check,
                            color: DozColors.primaryGreen,
                          )
                        : null,
                    onTap: () {
                      setState(() => _countryCode = c.$1);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }
}
