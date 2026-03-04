import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/app_router.dart';

/// OTP verification screen — 6 individual digit inputs with auto-advance.
class OtpScreen extends StatefulWidget {
  final String phone;
  final String countryCode;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.countryCode,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool _loading = false;
  bool _resending = false;
  int _resendCountdown = 60;
  Timer? _resendTimer;
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendCountdown = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown <= 1) {
        t.cancel();
        setState(() => _resendCountdown = 0);
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp(String otp) async {
    if (otp.length < 6 || _loading) return;

    setState(() => _loading = true);
    try {
      final result =
          await context.read<AuthProvider>().verifyOtp(otp: otp);
      if (!mounted) return;

      if (result.isNewUser) {
        context.go(AppRoutes.register, extra: {
          'phone': widget.phone,
        });
      } else {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('invalidOtp')),
          backgroundColor: DozColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0 || _resending) return;
    setState(() => _resending = true);
    try {
      await context.read<AuthProvider>().requestOtp(
            phone: widget.phone,
            countryCode: widget.countryCode,
          );
      _startResendTimer();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: DozColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final maskedPhone =
        '${widget.countryCode} ${widget.phone.replaceRange(3, widget.phone.length - 2, '****')}';

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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Title
                Text(
                  l10n.t('enterOtp'),
                  style: DozTextStyles.pageTitle(isArabic: isArabic),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${l10n.t('otpSent')} ',
                        style: DozTextStyles.bodyMedium(
                          isArabic: isArabic,
                          color: DozColors.textMuted,
                        ),
                      ),
                      TextSpan(
                        text: maskedPhone,
                        style: DozTextStyles.bodyMedium(
                          isArabic: false,
                          color: DozColors.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('otpExpiry'),
                  style: DozTextStyles.caption(
                    isArabic: isArabic,
                    color: DozColors.textDisabled,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // OTP Field
                DozOtpField(
                  length: 6,
                  onCompleted: (otp) {
                    setState(() => _otp = otp);
                    _verifyOtp(otp);
                  },
                  onChanged: (otp) => setState(() => _otp = otp),
                ),

                const SizedBox(height: 40),

                // Loading indicator
                if (_loading)
                  const Center(
                    child: DozLoading(size: 40),
                  )
                else ...[
                  // Verify button
                  DozButton(
                    label: l10n.t('verifyOtp'),
                    onPressed: _otp.length == 6 ? () => _verifyOtp(_otp) : null,
                  ),
                ],

                const Spacer(),

                // Resend OTP
                Center(
                  child: _resendCountdown > 0
                      ? RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${l10n.t('resendIn')} ',
                                style: DozTextStyles.bodyMedium(
                                  isArabic: isArabic,
                                  color: DozColors.textMuted,
                                ),
                              ),
                              TextSpan(
                                text: '$_resendCountdown ${isArabic ? 'ث' : 's'}',
                                style: DozTextStyles.bodyMedium(
                                  isArabic: false,
                                  color: DozColors.primaryGreen,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )
                      : TextButton(
                          onPressed: _resending ? null : _resendOtp,
                          child: _resending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                        DozColors.primaryGreen),
                                  ),
                                )
                              : Text(
                                  l10n.t('resendOtp'),
                                  style: DozTextStyles.bodyMedium(
                                    isArabic: isArabic,
                                    color: DozColors.primaryGreen,
                                  ).copyWith(fontWeight: FontWeight.w600),
                                ),
                        ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

