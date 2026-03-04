import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/app_router.dart';

/// Registration screen — shown after first-time OTP verification.
class RegisterScreen extends StatefulWidget {
  final String phone;

  const RegisterScreen({super.key, required this.phone});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _agreedToTerms = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.isArabic
                ? 'يجب الموافقة على الشروط والأحكام'
                : 'You must agree to the Terms & Conditions',
          ),
          backgroundColor: DozColors.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().register(
            _nameController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
          );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: DozColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
          color: DozColors.textPrimary,
        ),
      ),
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
                  const SizedBox(height: 16),

                  Text(
                    l10n.t('createAccount'),
                    style: DozTextStyles.pageTitle(isArabic: isArabic),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic
                        ? 'أدخل بياناتك لإنشاء حسابك'
                        : 'Enter your details to create your account',
                    style: DozTextStyles.bodyMedium(
                      isArabic: isArabic,
                      color: DozColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Name
                  DozTextField(
                    controller: _nameController,
                    label: l10n.t('fullName'),
                    hint: isArabic ? 'أدخل اسمك الكامل' : 'Enter your full name',
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: DozColors.textMuted,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return isArabic ? 'الاسم مطلوب' : 'Name is required';
                      }
                      if (v.trim().length < 2) {
                        return isArabic
                            ? 'الاسم قصير جداً'
                            : 'Name is too short';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Email (optional)
                  DozTextField(
                    controller: _emailController,
                    label:
                        '${l10n.t('email')} (${l10n.t('optional')})',
                    hint: isArabic
                        ? 'أدخل بريدك الإلكتروني'
                        : 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: DozColors.textMuted,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (!v.contains('@') || !v.contains('.')) {
                        return isArabic
                            ? 'بريد إلكتروني غير صحيح'
                            : 'Invalid email address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  // Terms & Conditions checkbox
                  GestureDetector(
                    onTap: () =>
                        setState(() => _agreedToTerms = !_agreedToTerms),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _agreedToTerms
                                ? DozColors.primaryGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _agreedToTerms
                                  ? DozColors.primaryGreen
                                  : DozColors.borderDark,
                              width: 1.5,
                            ),
                          ),
                          child: _agreedToTerms
                              ? const Icon(Icons.check_rounded,
                                  size: 14, color: DozColors.primaryDark)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: DozTextStyles.bodyMedium(
                                isArabic: isArabic,
                                color: DozColors.textSecondary,
                              ),
                              children: [
                                TextSpan(text: '${l10n.t('agreeToTerms')} '),
                                TextSpan(
                                  text: l10n.t('termsAndConditions'),
                                  style: const TextStyle(
                                    color: DozColors.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                  text: isArabic ? 'و' : 'and',
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                  text: l10n.t('privacyPolicy'),
                                  style: const TextStyle(
                                    color: DozColors.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Create Account button
                  DozButton(
                    label: l10n.t('createAccount'),
                    onPressed: _loading ? null : _createAccount,
                    loading: _loading,
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.t('alreadyHaveAccount'),
                          style: DozTextStyles.bodyMedium(
                            isArabic: isArabic,
                            color: DozColors.textMuted,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: Text(
                            l10n.t('login'),
                            style: DozTextStyles.bodyMedium(
                              isArabic: isArabic,
                              color: DozColors.primaryGreen,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
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
