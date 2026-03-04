import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/payments_provider.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/data_table_widget.dart';
import '../../widgets/search_filter_bar.dart';
import '../../widgets/confirm_dialog.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentsProvider>().loadTransactions(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Payments',
      actions: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Export'),
          style: ElevatedButton.styleFrom(
            backgroundColor: DozColors.surfaceLight,
            foregroundColor: DozColors.textSecondaryLight,
            side: const BorderSide(color: DozColors.borderLight),
            minimumSize: const Size(100, 36),
          ),
        ),
      ],
      child: Consumer<PaymentsProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Summary cards
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _SummaryCards(summary: provider.summary),
              ),

              // Filter bar
              SearchFilterBar(
                hintText: 'Search transactions...',
                onSearch: (_) {},
                chips: [
                  FilterChipData(
                    label: 'All',
                    isSelected: provider.typeFilter == null,
                    onTap: () => provider.setTypeFilter(null),
                  ),
                  FilterChipData(
                    label: 'Payments',
                    isSelected:
                        provider.typeFilter == WalletTransactionType.payment,
                    onTap: () => provider
                        .setTypeFilter(WalletTransactionType.payment),
                  ),
                  FilterChipData(
                    label: 'Top-ups',
                    isSelected:
                        provider.typeFilter == WalletTransactionType.topUp,
                    onTap: () => provider
                        .setTypeFilter(WalletTransactionType.topUp),
                  ),
                  FilterChipData(
                    label: 'Refunds',
                    isSelected:
                        provider.typeFilter == WalletTransactionType.refund,
                    onTap: () => provider
                        .setTypeFilter(WalletTransactionType.refund),
                  ),
                  FilterChipData(
                    label: 'Commission',
                    isSelected: provider.typeFilter ==
                        WalletTransactionType.commission,
                    onTap: () => provider
                        .setTypeFilter(WalletTransactionType.commission),
                  ),
                ],
              ),

              // Table
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: DozColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: DozColors.borderLight),
                    ),
                    child: AdminDataTable<WalletTransactionModel>(
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('DESCRIPTION')),
                        DataColumn(label: Text('TYPE')),
                        DataColumn(label: Text('AMOUNT'), numeric: true),
                        DataColumn(label: Text('BALANCE AFTER'), numeric: true),
                        DataColumn(label: Text('DATE')),
                      ],
                      rows: provider.transactions,
                      rowBuilder: (txn, index) => DataRow(
                        cells: [
                          DataCell(Text(
                            '#${txn.id.substring(0, 8).toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'RobotoMono',
                              color: DozColors.textMutedLight,
                            ),
                          )),
                          DataCell(SizedBox(
                            width: 200,
                            child: Text(
                              txn.description,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                          DataCell(_TransactionTypeBadge(type: txn.type)),
                          DataCell(
                            Text(
                              '${txn.isCredit ? '+' : '-'}${txn.amount.toStringAsFixed(3)} JOD',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                                color: txn.isCredit
                                    ? DozColors.success
                                    : DozColors.error,
                              ),
                            ),
                          ),
                          DataCell(Text(
                            '${txn.balanceAfter.toStringAsFixed(3)} JOD',
                            style: const TextStyle(fontFamily: 'Inter'),
                          )),
                          DataCell(Text(
                            '${DozFormatters.dateShort(txn.createdAt)} ${DozFormatters.time(txn.createdAt, lang: 'en')}',
                            style: const TextStyle(fontSize: 11),
                          )),
                        ],
                      ),
                      isLoading: provider.isLoading,
                      emptyMessage: 'No transactions found',
                      currentPage: provider.page,
                      totalPages: provider.totalPages,
                      totalItems: provider.total,
                      pageSize: 20,
                      onPageChanged: provider.goToPage,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final PaymentSummary summary;
  const _SummaryCards({required this.summary});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCardData(
        label: 'Total Payments',
        value: '${summary.totalAmount.toStringAsFixed(3)} JOD',
        icon: Icons.payment,
        color: DozColors.primaryGreen,
        bg: DozColors.primaryGreenSurface,
      ),
      _SummaryCardData(
        label: 'Commission Earned',
        value: '${summary.totalCommission.toStringAsFixed(3)} JOD',
        icon: Icons.account_balance,
        color: DozColors.success,
        bg: DozColors.successLight,
      ),
      _SummaryCardData(
        label: 'Wallet Top-ups',
        value: '${summary.totalTopUps.toStringAsFixed(3)} JOD',
        icon: Icons.account_balance_wallet,
        color: DozColors.info,
        bg: DozColors.infoLight,
      ),
      _SummaryCardData(
        label: 'Refunds',
        value: '${summary.totalRefunds.toStringAsFixed(3)} JOD',
        icon: Icons.undo,
        color: DozColors.error,
        bg: DozColors.errorLight,
      ),
    ];

    return Row(
      children: cards.map((c) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: cards.last == c ? 0 : 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DozColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DozColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(c.icon, size: 18, color: c.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: DozColors.textPrimaryLight,
                            fontFamily: 'Inter',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          c.label,
                          style: const TextStyle(
                            fontSize: 11,
                            color: DozColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SummaryCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
  const _SummaryCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });
}

class _TransactionTypeBadge extends StatelessWidget {
  final WalletTransactionType type;
  const _TransactionTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    Color color, bg;
    String label;
    switch (type) {
      case WalletTransactionType.payment:
        color = DozColors.info;
        bg = DozColors.infoLight;
        label = 'Payment';
        break;
      case WalletTransactionType.topUp:
        color = DozColors.success;
        bg = DozColors.successLight;
        label = 'Top-up';
        break;
      case WalletTransactionType.refund:
        color = DozColors.warning;
        bg = DozColors.warningLight;
        label = 'Refund';
        break;
      case WalletTransactionType.commission:
        color = DozColors.primaryGreen;
        bg = DozColors.primaryGreenSurface;
        label = 'Commission';
        break;
      case WalletTransactionType.withdrawal:
        color = DozColors.error;
        bg = DozColors.errorLight;
        label = 'Withdrawal';
        break;
    }
    return StatusBadge(label: label, color: color, bgColor: bg);
  }
}
