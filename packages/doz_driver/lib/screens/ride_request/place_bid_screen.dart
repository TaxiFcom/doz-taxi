import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/ride_provider.dart';
import 'widgets/ride_info_card.dart';
import 'widgets/bid_input.dart';

/// Place Bid Screen — driver sets their bid amount for a ride.
class PlaceBidScreen extends StatefulWidget {
  const PlaceBidScreen({super.key});

  @override
  State<PlaceBidScreen> createState() => _PlaceBidScreenState();
}

class _PlaceBidScreenState extends State<PlaceBidScreen> {
  double _bidAmount = 0;

  @override
  void initState() {
    super.initState();
    final ride = context.read<RideProvider>().currentRide;
    if (ride != null) _bidAmount = ride.suggestedPrice;
  }

  Future<void> _submitBid() async {
    final success = await context.read<RideProvider>().placeBid(_bidAmount);
    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final rideProvider = context.watch<RideProvider>();
    final ride = rideProvider.currentRide;
    if (ride == null) return Scaffold(backgroundColor: DozColors.primaryDark, body: Center(child: Text(l.t('noData'))));
    final commission = _bidAmount * AppConstants.commissionRate;
    final driverEarnings = _bidAmount - commission;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new, color: DozColors.textPrimary, size: 20)),
        title: Text(l.t('placeBid'), style: DozTextStyles.sectionTitle(isArabic: isAr)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RideInfoCard(ride: ride),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: DozColors.cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: DozColors.borderDark)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isAr ? 'سعر الراكب المقترح' : "Rider's suggested price", style: DozTextStyles.bodySmall(isArabic: isAr, color: DozColors.textMuted)),
                  Text(DozFormatters.currency(ride.suggestedPrice), style: DozTextStyles.priceMedium(color: DozColors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(l.t('bidAmount'), style: DozTextStyles.labelLarge(isArabic: isAr)),
            const SizedBox(height: 12),
            BidInput(value: _bidAmount, minValue: AppConstants.minRidePrice, maxValue: AppConstants.maxRidePrice, onChanged: (v) => setState(() => _bidAmount = v)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: DozColors.primaryGreenSurface, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: DozColors.primaryGreen, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    isAr ? 'النطاق المقترح: ${DozFormatters.currency(ride.suggestedPrice * 0.9)} - ${DozFormatters.currency(ride.suggestedPrice * 1.2)}' : 'Suggested range: ${DozFormatters.currency(ride.suggestedPrice * 0.9)} - ${DozFormatters.currency(ride.suggestedPrice * 1.2)}',
                    style: DozTextStyles.bodySmall(isArabic: isAr, color: DozColors.primaryGreen),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            DozCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isAr ? 'تفاصيل الأرباح' : 'Earnings Breakdown', style: DozTextStyles.labelLarge(isArabic: isAr)),
                  const SizedBox(height: 12),
                  _earningsRow(isAr ? 'قيمة العرض' : 'Your bid', DozFormatters.currency(_bidAmount), DozColors.textPrimary, isAr),
                  const SizedBox(height: 8),
                  _earningsRow(isAr ? 'عمولة المنصة (15%)' : 'Commission (15%)', '-${DozFormatters.currency(commission)}', DozColors.error, isAr),
                  const Divider(color: DozColors.borderDark, height: 20),
                  _earningsRow(isAr ? 'صافي أرباحك' : 'Your net earnings', DozFormatters.currency(driverEarnings), DozColors.primaryGreen, isAr, bold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(child: Text(isAr ? 'سيرى الراكب عرضك ويقرر' : 'The rider will see your offer and decide', style: DozTextStyles.caption(isArabic: isAr, color: DozColors.textMuted), textAlign: TextAlign.center)),
            const SizedBox(height: 16),
            if (rideProvider.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: DozColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: DozColors.error.withOpacity(0.3))),
                child: Text(rideProvider.errorMessage!, style: DozTextStyles.bodySmall(isArabic: isAr, color: DozColors.error)),
              ),
            DozButton(label: l.t('placeBid'), loading: rideProvider.isLoading, onPressed: _bidAmount > 0 ? _submitBid : null),
          ],
        ),
      ),
    );
  }

  Widget _earningsRow(String label, String value, Color valueColor, bool isAr, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: DozTextStyles.bodySmall(isArabic: isAr, color: bold ? DozColors.textPrimary : DozColors.textMuted)),
        Text(value, style: bold ? DozTextStyles.priceMedium(color: valueColor) : DozTextStyles.bodySmall(isArabic: false, color: valueColor)),
      ],
    );
  }
}
