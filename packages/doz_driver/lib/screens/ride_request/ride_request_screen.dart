import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/ride_provider.dart';
import '../../navigation/app_router.dart';

/// Displays the details of an incoming ride request.
class RideRequestScreen extends StatelessWidget {
  const RideRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final ride = context.watch<RideProvider>();
    final r = ride.currentRide;
    if (r == null) return Scaffold(backgroundColor: DozColors.primaryDark, body: Center(child: Text(l.t('noData'), style: DozTextStyles.bodyMedium(isArabic: isAr))));

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new, color: DozColors.textPrimary, size: 20)),
        title: Text(l.t('newRideRequest'), style: DozTextStyles.sectionTitle(isArabic: isAr)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimer(ride.requestTimerSeconds, isAr),
            const SizedBox(height: 20),
            if (r.rider != null) _buildRiderCard(r, isAr),
            const SizedBox(height: 16),
            _buildRideInfoCard(r, isAr, l),
            const SizedBox(height: 16),
            _buildPriceSection(r, isAr),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: DozButton(label: isAr ? 'رفض' : 'Decline', variant: DozButtonVariant.danger, onPressed: () { context.read<RideProvider>().declineRequest(); context.pop(); })),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: DozButton(label: l.t('placeBid'), onPressed: () { context.read<RideProvider>().openBidScreen(); context.push(AppRoutes.placeBid); })),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer(int seconds, bool isAr) {
    final isUrgent = seconds <= 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUrgent ? DozColors.error.withOpacity(0.1) : DozColors.primaryGreenSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUrgent ? DozColors.error.withOpacity(0.3) : DozColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: isUrgent ? DozColors.error : DozColors.primaryGreen, size: 20),
          const SizedBox(width: 8),
          Text(isAr ? 'ينتهي خلال ${seconds}ث' : 'Expires in ${seconds}s',
            style: DozTextStyles.bodyMedium(isArabic: isAr).copyWith(color: isUrgent ? DozColors.error : DozColors.primaryGreen, fontWeight: FontWeight.w600)),
          const Spacer(),
          SizedBox(width: 80, child: ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: seconds / 30.0, backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(isUrgent ? DozColors.error : DozColors.primaryGreen)))),
        ],
      ),
    );
  }

  Widget _buildRiderCard(RideModel r, bool isAr) {
    return DozCard(
      child: Row(
        children: [
          DozAvatar(imageUrl: r.rider!.avatarUrl, name: r.rider!.name, size: 52),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.rider!.name, style: DozTextStyles.sectionTitle(isArabic: isAr)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text('4.8', style: DozTextStyles.bodySmall(isArabic: false)),
                  const SizedBox(width: 8),
                  Text(isAr ? '٤٢ رحلة' : '42 rides', style: DozTextStyles.caption(isArabic: isAr)),
                ]),
              ],
            ),
          ),
          DozStatusBadge(label: r.paymentMethod == PaymentMethod.cash ? (isAr ? 'نقدي' : 'Cash') : (isAr ? 'محفظة' : 'Wallet'), backgroundColor: DozColors.info),
        ],
      ),
    );
  }

  Widget _buildRideInfoCard(RideModel r, bool isAr, AppLocalizations l) {
    return DozCard(
      child: Column(
        children: [
          _addressRow(icon: Icons.location_on, iconColor: DozColors.primaryGreen, label: isAr ? 'نقطة الانطلاق' : 'Pickup', address: r.pickupAddress, isAr: isAr),
          const SizedBox(height: 4),
          Padding(padding: const EdgeInsets.only(left: 16), child: Column(children: List.generate(3, (i) => Container(margin: const EdgeInsets.symmetric(vertical: 2), width: 2, height: 6, decoration: BoxDecoration(color: DozColors.borderDark, borderRadius: BorderRadius.circular(1)))))),
          const SizedBox(height: 4),
          _addressRow(icon: Icons.flag, iconColor: DozColors.error, label: isAr ? 'نقطة الوصول' : 'Destination', address: r.dropoffAddress, isAr: isAr),
          const Divider(color: DozColors.borderDark, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (r.distanceKm != null) _stat(Icons.straighten, DozFormatters.distance(r.distanceKm!), isAr ? 'المسافة' : 'Distance', isAr),
              if (r.durationMin != null) _stat(Icons.access_time, DozFormatters.duration(r.durationMin!), isAr ? 'الوقت' : 'Duration', isAr),
              _stat(Icons.account_balance_wallet_outlined, r.paymentMethod == PaymentMethod.cash ? (isAr ? 'نقدي' : 'Cash') : (isAr ? 'محفظة' : 'Wallet'), isAr ? 'الدفع' : 'Payment', isAr),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(RideModel r, bool isAr) {
    final commission = r.suggestedPrice * AppConstants.commissionRate;
    final earnings = r.suggestedPrice - commission;
    return DozCard(
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(isAr ? 'سعر الراكب المقترح' : "Rider's Suggested Price", style: DozTextStyles.bodyMedium(isArabic: isAr)),
            Text(DozFormatters.currency(r.suggestedPrice), style: DozTextStyles.priceMedium(color: DozColors.textPrimary)),
          ]),
          const Divider(color: DozColors.borderDark, height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(isAr ? 'عمولة المنصة (15%)' : 'Platform commission (15%)', style: DozTextStyles.bodySmall(isArabic: isAr, color: DozColors.textMuted)),
            Text('-${DozFormatters.currency(commission)}', style: DozTextStyles.bodySmall(isArabic: false, color: DozColors.error)),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: DozColors.primaryGreenSurface, borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(isAr ? 'أرباحك المتوقعة' : 'Your potential earnings', style: DozTextStyles.labelLarge(isArabic: isAr, color: DozColors.primaryGreen)),
              Text(DozFormatters.currency(earnings), style: DozTextStyles.priceMedium(color: DozColors.primaryGreen)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _addressRow({required IconData icon, required Color iconColor, required String label, required String address, required bool isAr}) {
    return Row(
      children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: iconColor.withOpacity(0.12), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 16)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: DozTextStyles.caption(isArabic: isAr)),
          Text(address, style: DozTextStyles.bodySmall(isArabic: isAr), maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
      ],
    );
  }

  Widget _stat(IconData icon, String value, String label, bool isAr) {
    return Column(children: [
      Icon(icon, color: DozColors.textMuted, size: 18),
      const SizedBox(height: 4),
      Text(value, style: DozTextStyles.labelMedium(isArabic: false).copyWith(color: DozColors.textPrimary)),
      Text(label, style: DozTextStyles.caption(isArabic: isAr)),
    ]);
  }
}
