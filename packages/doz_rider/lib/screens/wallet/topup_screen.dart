import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/wallet_provider.dart';

/// Top-up screen — choose amount and payment method to add money.
class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _customAmountController = TextEditingController();
  double? _selectedPreset;
  String _paymentMethod = 'card';
  bool _loading = false;

  final List<double> _presets = [5, 10, 20, 50];

  double get _amount {
    if (_selectedPreset != null) return _selectedPreset!;
    return double.tryParse(_customAmountController.text) ?? 0;
  }

  bool get _isValid => _amount >= AppConstants.minTopUpAmount;

  Future<void> _topUp() async {
    if (!_isValid) return;
    setState(() => _loading = true);
    try {
      await context.read<WalletProvider>().topUp(
            amount: _amount,
            paymentMethod: _paymentMethod,
          );
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).isArabic
                ? 'تم شحن المحفظة بنجاح'
                : 'Wallet topped up successfully',
          ),
          backgroundColor: DozColors.success,
        ),
      );
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
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: DozColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
          color: DozColors.textPrimary,
        ),
        title: Text(
          isArabic ? 'شحن المحفظة' : 'Top Up Wallet',
          style: DozTextStyles.sectionTitle(isArabic: isArabic),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: DozColors.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // Amount selection
                Text(
                  isArabic ? 'اختر المبلغ' : 'Choose Amount',
                  style: DozTextStyles.sectionTitle(isArabic: isArabic),
                ),
                const SizedBox(height: 16),

                // Preset amounts
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: _presets.map((amount) {
                    final isSelected = _selectedPreset == amount;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPreset = amount;
                          _customAmountController.clear();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? DozColors.primaryGreenSurface
                              : DozColors.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? DozColors.primaryGreen
                                : DozColors.borderDark,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${amount.toStringAsFixed(0)} JOD',
                            style: DozTextStyles.sectionTitle(
                              isArabic: false,
                              color: isSelected
                                  ? DozColors.primaryGreen
                                  : DozColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Custom amount
                DozTextField(
                  controller: _customAmountController,
                  label: isArabic ? 'مبلغ آخر' : 'Custom Amount',
                  hint: 'e.g. 15.000',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(
                    Icons.edit_rounded,
                    color: DozColors.textMuted,
                    size: 18,
                  ),
                  onChanged: (v) {
                    setState(() => _selectedPreset = null);
                  },
                ),

                const SizedBox(height: 28),

                // Payment method
                Text(
                  isArabic ? 'طريقة الدفع' : 'Payment Method',
                  style: DozTextStyles.sectionTitle(isArabic: isArabic),
                ),
                const SizedBox(height: 12),

                _PaymentMethodOption(
                  icon: Icons.credit_card_rounded,
                  label: isArabic ? 'بطاقة ائتمان / مدين' : 'Credit / Debit Card',
                  value: 'card',
                  selected: _paymentMethod == 'card',
                  onSelect: () => setState(() => _paymentMethod = 'card'),
                ),
                const SizedBox(height: 8),
                _PaymentMethodOption(
                  icon: Icons.account_balance_rounded,
                  label: isArabic ? 'تحويل بنكي' : 'Bank Transfer',
                  value: 'bank',
                  selected: _paymentMethod == 'bank',
                  onSelect: () => setState(() => _paymentMethod = 'bank'),
                ),

                const SizedBox(height: 32),

                // Summary
                if (_isValid)
                  DozCard(
                    color: DozColors.primaryGreenSurface,
                    borderColor: DozColors.primaryGreen,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? 'المبلغ المراد شحنه' : 'Amount to top up',
                          style: DozTextStyles.bodyMedium(isArabic: isArabic),
                        ),
                        Text(
                          '${_amount.toStringAsFixed(3)} JOD',
                          style: DozTextStyles.priceMedium()
                              .copyWith(color: DozColors.primaryGreen),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                DozButton(
                  label: isArabic ? 'شحن المحفظة' : 'Top Up',
                  onPressed: _isValid && !_loading ? _topUp : null,
                  loading: _loading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onSelect;

  const _PaymentMethodOption({
    required this.icon,
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? DozColors.primaryGreenSurface : DozColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? DozColors.primaryGreen : DozColors.borderDark,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? DozColors.primaryGreen : DozColors.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: DozTextStyles.bodyMedium(isArabic: isArabic)
                    .copyWith(
                  color: selected
                      ? DozColors.primaryGreen
                      : DozColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? DozColors.primaryGreen : DozColors.borderDark,
                  width: 2,
                ),
                color: selected ? DozColors.primaryGreen : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 12, color: DozColors.primaryDark)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
