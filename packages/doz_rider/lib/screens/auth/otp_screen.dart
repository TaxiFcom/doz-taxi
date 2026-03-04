import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

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
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    final otp = _controllers.map((c) => c.text).join();
    setState(() => _otp = otp);
    if (otp.length == 6) {
      _verifyOtp(otp);
    }
  }

  Future<void> _verifyOtp(String otp) async {
    if (otp.length < 6 || _loading) return;

    setState(() => _loading = true);
    try {
      final result = await context
          .read<AuthProvider>()
          .verifyOtp(widget.phone, widget.countryCode, otp);
      if (!mounted) return;

      if (result['isNewUser'] == true) {
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
      await context
          .read<AuthProvider>()
          .sendOtp(widget.phone, widget.countryCode);
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

                // OTP Fields — 6 individual digit boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 44,
                      height: 54,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: DozTextStyles.sectionTitle(isArabic: false)
                            .copyWith(fontSize: 22),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
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
                        onChanged: (v) => _onDigitChanged(index, v),
                      ),
                    );
                  }),
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
