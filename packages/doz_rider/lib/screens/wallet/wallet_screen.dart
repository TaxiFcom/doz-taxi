import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/wallet_provider.dart';
import '../../navigation/app_router.dart';

/// Wallet screen — balance card and transaction history.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().loadWallet();
      context.read<WalletProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final walletProvider = context.watch<WalletProvider>();

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
          isArabic ? 'المحفظة' : 'Wallet',
          style: DozTextStyles.sectionTitle(isArabic: isArabic),
        ),
        centerTitle: true,
      ),
      body: walletProvider.loading
          ? const Center(child: DozLoading())
          : RefreshIndicator(
              onRefresh: () async {
                await walletProvider.loadWallet();
                await walletProvider.loadTransactions(refresh: true);
              },
              color: DozColors.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Balance card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: DozColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: DozColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            isArabic ? 'رصيدك الحالي' : 'Your Balance',
                            style: DozTextStyles.bodyMedium(
                              isArabic: isArabic,
                              color: DozColors.primaryDark.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                walletProvider.balance.toStringAsFixed(3),
                                style: DozTextStyles.priceHero(
                                  color: DozColors.primaryDark,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                walletProvider.currency,
                                style: DozTextStyles.sectionTitle(
                                  isArabic: false,
                                  color: DozColors.primaryDark.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          DozButton(
                            label: isArabic ? 'شحن المحفظة' : 'Top Up',
                            onPressed: () => context.push(AppRoutes.topup),
                            variant: DozButtonVariant.secondary,
                            height: 44,
                            prefixIcon: const Icon(
                              Icons.add_circle_outline_rounded,
                              size: 18,
                              color: DozColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Transactions header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isArabic ? 'المعاملات' : 'Transactions',
                          style:
                              DozTextStyles.sectionTitle(isArabic: isArabic),
                        ),
                        if (walletProvider.transactions.isNotEmpty)
                          Text(
                            '${walletProvider.transactions.length}',
                            style: DozTextStyles.bodySmall(isArabic: isArabic,
                                color: DozColors.textMuted),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Transactions
                    if (walletProvider.transactionsLoading)
                      const Center(
                          child: Padding(
                        padding: EdgeInsets.all(32),
                        child: DozLoading(),
                      ))
                    else if (walletProvider.transactions.isEmpty)
                      DozEmptyState(
                        icon: Icons.receipt_long_rounded,
                        title: isArabic ? 'لا توجد معاملات' : 'No transactions',
                        subtitle: isArabic
                            ? 'ستظهر هنا معاملاتك عند الشحن أو الدفع'
                            : 'Your transactions will appear here',
                      )
                    else
                      ...walletProvider.transactions.map(
                        (t) => _TransactionItem(transaction: t),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final WalletTransactionModel transaction;

  const _TransactionItem({required this.transaction});

  IconData _getIcon() {
    switch (transaction.type) {
      case WalletTransactionType.topUp:
        return Icons.add_circle_rounded;
      case WalletTransactionType.payment:
        return Icons.directions_car_rounded;
      case WalletTransactionType.refund:
        return Icons.replay_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  Color _getColor() {
    if (transaction.isCredit) return DozColors.success;
    return DozColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    final isCredit = transaction.isCredit;

    return DozCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(), color: _getColor(), size: 22),
          ),
          const SizedBox(width: 12),

          // Description + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: DozTextStyles.bodyMedium(isArabic: isArabic)
                      .copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DozFormatters.timeAgo(transaction.createdAt,
                      lang: isArabic ? 'ar' : 'en'),
                  style: DozTextStyles.caption(isArabic: isArabic),
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${transaction.amount.toStringAsFixed(3)}',
                style: DozTextStyles.bodyMedium(isArabic: false)
                    .copyWith(
                  color: _getColor(),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'JOD',
                style: DozTextStyles.caption(isArabic: false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
