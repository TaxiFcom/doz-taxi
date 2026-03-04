import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../navigation/app_router.dart';

/// Wallet screen showing balance and transaction history.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  WalletModel? _wallet;
  List<WalletTransactionModel> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _wallet = WalletModel(id: 'w1', userId: 'u1', balance: 47.500, currency: 'JOD', updatedAt: DateTime.now());
        _isLoading = false;
      });
    } catch (e) { setState(() { _error = e.toString(); _isLoading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: DozColors.surfaceDark, elevation: 0,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new, color: DozColors.textPrimary, size: 20)),
        title: Text(isAr ? 'المحفظة' : 'Wallet', style: DozTextStyles.sectionTitle(isArabic: isAr)),
        centerTitle: true,
      ),
      body: _isLoading ? const Center(child: DozLoading())
          : RefreshIndicator(
              color: DozColors.primaryGreen, backgroundColor: DozColors.cardDark, onRefresh: _loadWallet,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(isAr),
                    const SizedBox(height: 20),
                    DozButton(label: isAr ? 'طلب سحب' : 'Request Payout', prefixIcon: const Icon(Icons.account_balance, color: DozColors.primaryDark, size: 20), onPressed: () => context.push(AppRoutes.withdraw)),
                    const SizedBox(height: 24),
                    Text(isAr ? 'سجل المعاملات' : 'Transaction History', style: DozTextStyles.labelLarge(isArabic: isAr)),
                    const SizedBox(height: 12),
                    if (_transactions.isEmpty)
                      Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 32), child: DozEmptyState(icon: Icons.receipt_long_outlined, title: isAr ? 'لا توجد معاملات' : 'No transactions', subtitle: isAr ? 'ستظهر معاملاتك هنا' : 'Your transactions will appear here')))
                    else ..._transactions.map((t) => _TransactionCard(transaction: t, isAr: isAr)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard(bool isAr) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: DozColors.darkGradient, borderRadius: BorderRadius.circular(20), border: Border.all(color: DozColors.primaryGreen.withOpacity(0.2)), boxShadow: [BoxShadow(color: DozColors.primaryGreen.withOpacity(0.05), blurRadius: 24)]),
      child: Column(
        children: [
          Container(width: 52, height: 52, decoration: BoxDecoration(color: DozColors.primaryGreenSurface, shape: BoxShape.circle, border: Border.all(color: DozColors.primaryGreen.withOpacity(0.4))), child: const Icon(Icons.account_balance_wallet, color: DozColors.primaryGreen, size: 26)),
          const SizedBox(height: 12),
          Text(isAr ? 'الرصيد المتاح' : 'Available Balance', style: DozTextStyles.bodySmall(isArabic: isAr, color: DozColors.textMuted)),
          const SizedBox(height: 6),
          Text(DozFormatters.currency(_wallet?.balance ?? 0), style: DozTextStyles.priceHero(color: DozColors.primaryGreen)),
          Text(AppConstants.defaultCurrency, style: DozTextStyles.caption(isArabic: isAr, color: DozColors.textMuted)),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final WalletTransactionModel transaction;
  final bool isAr;
  const _TransactionCard({required this.transaction, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: DozColors.surfaceDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: DozColors.borderDark)),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: isCredit ? DozColors.success.withOpacity(0.12) : DozColors.error.withOpacity(0.12), shape: BoxShape.circle), child: Icon(isCredit ? Icons.add : Icons.remove, color: isCredit ? DozColors.success : DozColors.error, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(transaction.description, style: DozTextStyles.bodySmall(isArabic: isAr)),
            Text(DozFormatters.timeAgo(transaction.createdAt, lang: isAr ? 'ar' : 'en'), style: DozTextStyles.caption(isArabic: isAr)),
          ])),
          Text('${isCredit ? '+' : '-'}${DozFormatters.currency(transaction.amount)}', style: DozTextStyles.bodyMedium(isArabic: false).copyWith(color: isCredit ? DozColors.success : DozColors.error, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
