import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/earnings_provider.dart';
import 'widgets/earnings_chart.dart';
import 'widgets/earnings_summary.dart';
import 'widgets/trip_earnings_card.dart';

/// Full earnings dashboard screen.
class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EarningsProvider>().loadEarnings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final earnings = context.watch<EarningsProvider>();

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: DozColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: DozColors.textPrimary, size: 20),
        ),
        title: Text(
          l.t('earnings'),
          style: DozTextStyles.sectionTitle(isArabic: isAr),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: DozColors.primaryGreen,
        backgroundColor: DozColors.cardDark,
        onRefresh: () => earnings.loadEarnings(earnings.period),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period selector
              _buildPeriodSelector(earnings, l, isAr),
              const SizedBox(height: 24),
              // Hero total earnings
              _buildHeroCard(earnings, isAr),
              const SizedBox(height: 20),
              // Summary cards
              EarningsSummaryCards(
                summary: earnings.summary,
                isLoading: earnings.isLoading,
              ),
              const SizedBox(height: 24),
              // Chart
              if (earnings.summary != null &&
                  earnings.summary!.dailyBreakdown.isNotEmpty) ...[
                Text(
                  isAr ? 'الأرباح اليومية' : 'Daily Earnings',
                  style: DozTextStyles.labelLarge(isArabic: isAr),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DozColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: DozColors.borderDark),
                  ),
                  child: EarningsChart(
                    data: earnings.summary!.dailyBreakdown,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // Recent trips
              if (earnings.summary != null &&
                  earnings.summary!.recentRides.isNotEmpty) ...[
                Text(
                  isAr ? 'الرحلات الأخيرة' : 'Recent Trips',
                  style: DozTextStyles.labelLarge(isArabic: isAr),
                ),
                const SizedBox(height: 12),
                ...earnings.summary!.recentRides.map(
                  (r) => TripEarningsCard(ride: r, isAr: isAr),
                ),
              ],
              // Loading state
              if (earnings.isLoading && !earnings.hasLoaded)
                const Center(child: DozLoading()),
              // Error state
              if (earnings.errorMessage != null)
                Center(
                  child: DozEmptyState(
                    icon: Icons.error_outline,
                    title: l.t('error'),
                    subtitle: earnings.errorMessage!,
                    actionLabel: l.t('retry'),
                    onAction: () => earnings.loadEarnings(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(
      EarningsProvider earnings, AppLocalizations l, bool isAr) {
    const periods = [
      EarningsPeriod.today,
      EarningsPeriod.week,
      EarningsPeriod.month,
    ];

    return Container(
      decoration: BoxDecoration(
        color: DozColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DozColors.borderDark),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: periods.map((p) {
          final isSelected = earnings.period == p;
          final label = p == EarningsPeriod.today
              ? l.t('today')
              : p == EarningsPeriod.week
                  ? l.t('weekEarnings').replaceAll('أرباح ', '').replaceAll(' Earnings', '')
                  : l.t('monthEarnings').replaceAll('أرباح ', '').replaceAll(' Earnings', '');

          return Expanded(
            child: GestureDetector(
              onTap: () => earnings.setPeriod(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DozColors.primaryGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: DozTextStyles.bodySmall(isArabic: isAr).copyWith(
                    color: isSelected
                        ? DozColors.primaryDark
                        : DozColors.textMuted,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeroCard(EarningsProvider earnings, bool isAr) {
    final net = earnings.summary?.netEarnings ?? earnings.todayEarnings;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: DozColors.darkGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: DozColors.primaryGreen.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: DozColors.primaryGreen.withOpacity(0.05),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isAr ? 'إجمالي أرباحك' : 'Total Net Earnings',
            style: DozTextStyles.bodySmall(
                isArabic: isAr, color: DozColors.textMuted),
          ),
          const SizedBox(height: 8),
          if (earnings.isLoading)
            const SizedBox(
              height: 60,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      DozColors.primaryGreen),
                ),
              ),
            )
          else
            Text(
              DozFormatters.currency(net),
              style: DozTextStyles.priceHero(
                  color: DozColors.primaryGreen),
            ),
          const SizedBox(height: 4),
          Text(
            AppConstants.defaultCurrency,
            style: DozTextStyles.caption(
                isArabic: isAr, color: DozColors.textMuted),
          ),
        ],
      ),
    );
  }
}
