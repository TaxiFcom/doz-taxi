import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../navigation/app_router.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _resendTimer;
  int _resendCooldown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startResendTimer() {
    _resendCooldown = 60;
    _canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) {
          _canResend = true;
          t.cancel();
        }
      });
    });
  }

  String get _otp =>
      _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length < 6) return;

    final auth = context.read<AuthProvider>();
    final result = await auth.verifyOtp(_otp);

    if (!mounted) return;

    if (auth.state == AuthState.needsRegistration) {
      context.go(AppRoutes.register);
    } else if (auth.isAuthenticated) {
      await context.read<DriverProvider>().init();
      if (mounted) context.go(AppRoutes.home);
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;

    final auth = context.read<AuthProvider>();
    await auth.requestOtp(
      phone: auth.phone,
      countryCode: auth.countryCode,
    );

    _startResendTimer();
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: DozColors.textPrimary, size: 20),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                l.t('verifyOtp'),
                style: DozTextStyles.pageTitle(isArabic: isAr),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: DozTextStyles.bodyMedium(
                    isArabic: isAr,
                    color: DozColors.textMuted,
                  ),
                  children: [
                    TextSpan(text: '${l.t('otpSent')} '),
                    TextSpan(
                      text: '${auth.countryCode}${auth.phone}',
                      style: DozTextStyles.bodyMedium(
                        isArabic: false,
                        color: DozColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.t('otpExpiry'),
                style: DozTextStyles.caption(
                  isArabic: isAr,
                  color: DozColors.textMuted,
                ),
              ),
              const SizedBox(height: 40),
              // OTP input boxes
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    return SizedBox(
                      width: 48,
                      height: 56,
                      child: TextFormField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: DozTextStyles.sectionTitle(isArabic: false)
                            .copyWith(
                          color: DozColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: DozColors.cardDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: DozColors.borderDark,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: DozColors.primaryGreen,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (v) {
                          if (v.isNotEmpty && i < 5) {
                            _focusNodes[i + 1].requestFocus();
                          } else if (v.isEmpty && i > 0) {
                            _focusNodes[i - 1].requestFocus();
                          }
                          if (_otp.length == 6) {
                            _verify();
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),
              // Error message
              if (auth.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DozColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: DozColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: DozColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          auth.errorMessage!,
                          style: DozTextStyles.bodySmall(
                              isArabic: isAr, color: DozColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              DozButton(
                label: l.t('verifyOtp'),
                loading: auth.isLoading,
                onPressed: _otp.length == 6 ? _verify : null,
              ),
              const SizedBox(height: 24),
              // Resend button
              Center(
                child: _canResend
                    ? TextButton(
                        onPressed: _resend,
                        child: Text(
                          l.t('resendOtp'),
                          style: DozTextStyles.buttonSmall(
                            isArabic: isAr,
                            color: DozColors.primaryGreen,
                          ),
                        ),
                      )
                    : Text(
                        '${l.t('resendIn')} ${_resendCooldown}s',
                        style: DozTextStyles.bodySmall(
                          isArabic: isAr,
                          color: DozColors.textMuted,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
