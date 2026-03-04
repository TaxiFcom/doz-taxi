import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:doz_shared/doz_shared.dart';

/// Withdraw/Payout request screen.
class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _ibanController = TextEditingController();
  bool _isLoading = false;
  double _availableBalance = 47.500;

  @override
  void dispose() {
    _amountController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) { setState(() => _isLoading = false); _showSuccessDialog(); }
  }

  void _showSuccessDialog() {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: DozColors.cardDark,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: DozColors.primaryGreen, size: 56),
            const SizedBox(height: 16),
            Text(isAr ? 'تم إرسال طلب السحب' : 'Withdrawal Requested', style: DozTextStyles.sectionTitle(isArabic: isAr), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(isAr ? 'سيتم تحويل المبلغ خلال 1-3 أيام عمل' : 'Amount will be transferred within 1-3 business days', style: DozTextStyles.bodySmall(isArabic: isAr, color: DozColors.textMuted), textAlign: TextAlign.center),
          ],
        ),
        actions: [DozButton(label: l.t('ok'), height: 44, onPressed: () { Navigator.pop(ctx); context.pop(); })],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new, color: DozColors.textPrimary, size: 20)),
        title: Text(isAr ? 'طلب سحب' : 'Request Payout', style: DozTextStyles.sectionTitle(isArabic: isAr)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: DozColors.darkGradient, borderRadius: BorderRadius.circular(16), border: Border.all(color: DozColors.primaryGreen.withOpacity(0.2))),
                child: Row(children: [
                  const Icon(Icons.account_balance_wallet, color: DozColors.primaryGreen, size: 28),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(isAr ? 'الرصيد المتاح للسحب' : 'Available for withdrawal', style: DozTextStyles.caption(isArabic: isAr)),
                    Text(DozFormatters.currency(_availableBalance), style: DozTextStyles.priceLarge(color: DozColors.primaryGreen)),
                  ]),
                ]),
              ),
              const SizedBox(height: 32),
              Text(isAr ? 'مبلغ السحب' : 'Withdrawal Amount', style: DozTextStyles.labelLarge(isArabic: isAr)),
              const SizedBox(height: 8),
              DozTextField(controller: _amountController, hint: '0.000', keyboardType: TextInputType.number,
                suffixIcon: Padding(padding: const EdgeInsets.all(14), child: Text(AppConstants.defaultCurrency, style: DozTextStyles.labelMedium(isArabic: false).copyWith(color: DozColors.primaryGreen))),
                validator: (v) {
                  if (v == null || v.isEmpty) return l.t('required_');
                  final amount = double.tryParse(v);
                  if (amount == null || amount <= 0) return isAr ? 'أدخل مبلغاً صحيحاً' : 'Enter valid amount';
                  if (amount > _availableBalance) return isAr ? 'تجاوزت الرصيد المتاح' : 'Exceeds available balance';
                  if (amount < 5) return isAr ? 'الحد الأدنى 5 JOD' : 'Minimum 5 JOD';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(isAr ? 'رقم الآيبان' : 'IBAN', style: DozTextStyles.labelLarge(isArabic: isAr)),
              const SizedBox(height: 8),
              DozTextField(controller: _ibanController, hint: 'JO29CBJO0000000000123456789',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l.t('required_');
                  if (v.trim().length < 16) return isAr ? 'رقم آيبان غير صحيح' : 'Invalid IBAN';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: DozColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: DozColors.info.withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Icons.info_outline, color: DozColors.info, size: 18), const SizedBox(width: 10),
                  Expanded(child: Text(isAr ? 'سيتم تحويل المبلغ خلال 1-3 أيام عمل' : 'Transfer will be processed within 1-3 business days', style: DozTextStyles.bodySmall(isArabic: isAr, color: DozColors.info))),
                ]),
              ),
              const SizedBox(height: 32),
              DozButton(label: isAr ? 'تأكيد طلب السحب' : 'Confirm Withdrawal', loading: _isLoading, onPressed: _submitWithdrawal),
            ],
          ),
        ),
      ),
    );
  }
}
