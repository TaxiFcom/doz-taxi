import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';

/// Full ride detail screen with map, earnings breakdown, and rating.
class RideDetailScreen extends StatefulWidget {
  final String rideId;
  const RideDetailScreen({super.key, required this.rideId});

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  RideModel? _ride;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRide();
  }

  Future<void> _loadRide() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isLoading = false);
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
        title: Text(isAr ? 'تفاصيل الرحلة' : 'Ride Details', style: DozTextStyles.sectionTitle(isArabic: isAr)),
        centerTitle: true,
      ),
      body: _isLoading ? const Center(child: DozLoading())
          : _ride == null ? Center(child: DozEmptyState(icon: Icons.directions_car_outlined, title: l.t('noData'), subtitle: isAr ? 'تعذر تحميل تفاصيل الرحلة' : 'Could not load ride details', actionLabel: l.t('retry'), onAction: _loadRide))
          : _buildContent(isAr, l),
    );
  }

  Widget _buildContent(bool isAr, AppLocalizations l) {
    final r = _ride!;
    final fare = r.finalPrice ?? r.suggestedPrice;
    final commission = fare * AppConstants.commissionRate;
    final net = fare - commission;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            DozStatusBadge(label: r.status == RideStatus.completed ? (isAr ? 'مكتملة' : 'Completed') : r.status == RideStatus.cancelled ? (isAr ? 'ملغاة' : 'Cancelled') : r.status.name, backgroundColor: r.status == RideStatus.completed ? DozColors.success : DozColors.error),
            const Spacer(),
            Text(DozFormatters.date(r.createdAt, lang: isAr ? 'ar' : 'en'), style: DozTextStyles.caption(isArabic: isAr)),
          ]),
          const SizedBox(height: 20),
          DozCard(child: Column(children: [
            _addressRow(Icons.location_on, DozColors.primaryGreen, isAr ? 'الانطلاق' : 'Pickup', r.pickupAddress, isAr),
            const SizedBox(height: 12),
            _addressRow(Icons.flag, DozColors.error, isAr ? 'الوصول' : 'Destination', r.dropoffAddress, isAr),
          ])),
          const SizedBox(height: 16),
          DozCard(child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            if (r.distanceKm != null) _stat(Icons.straighten, DozFormatters.distance(r.distanceKm!), isAr ? 'المسافة' : 'Distance', isAr),
            if (r.durationMin != null) _stat(Icons.access_time, DozFormatters.duration(r.durationMin!), isAr ? 'المدة' : 'Duration', isAr),
            _stat(Icons.payment, r.paymentMethod == PaymentMethod.cash ? (isAr ? 'نقدي' : 'Cash') : (isAr ? 'محفظة' : 'Wallet'), isAr ? 'الدفع' : 'Payment', isAr),
          ])),
          const SizedBox(height: 16),
          DozCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isAr ? 'تفاصيل الأرباح' : 'Earnings', style: DozTextStyles.labelLarge(isArabic: isAr)),
            const SizedBox(height: 12),
            _earningsRow(isAr ? 'قيمة الرحلة' : 'Ride Fare', DozFormatters.currency(fare), DozColors.textPrimary, isAr),
            const SizedBox(height: 8),
            _earningsRow(isAr ? 'عمولة المنصة' : 'Commission', '-${DozFormatters.currency(commission)}', DozColors.error, isAr),
            const Divider(color: DozColors.borderDark, height: 20),
            _earningsRow(isAr ? 'صافي أرباحك' : 'Net Earnings', DozFormatters.currency(net), DozColors.primaryGreen, isAr, bold: true),
          ])),
          if (r.rider != null) ...[
            const SizedBox(height: 16),
            DozCard(child: Row(children: [
              DozAvatar(imageUrl: r.rider!.avatarUrl, name: r.rider!.name, size: 44),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.rider!.name, style: DozTextStyles.labelLarge(isArabic: isAr)),
                const Row(children: [Icon(Icons.star, color: Colors.amber, size: 14), SizedBox(width: 4), Text('4.8')]),
              ])),
            ])),
          ],
        ],
      ),
    );
  }

  Widget _addressRow(IconData icon, Color color, String label, String address, bool isAr) {
    return Row(children: [
      Icon(icon, color: color, size: 18), const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: DozTextStyles.caption(isArabic: isAr)),
        Text(address, style: DozTextStyles.bodySmall(isArabic: isAr), maxLines: 2, overflow: TextOverflow.ellipsis),
      ])),
    ]);
  }

  Widget _stat(IconData icon, String value, String label, bool isAr) {
    return Column(children: [Icon(icon, color: DozColors.textMuted, size: 18), const SizedBox(height: 4), Text(value, style: DozTextStyles.labelMedium(isArabic: false).copyWith(color: DozColors.textPrimary)), Text(label, style: DozTextStyles.caption(isArabic: isAr))]);
  }

  Widget _earningsRow(String label, String value, Color color, bool isAr, {bool bold = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: DozTextStyles.bodySmall(isArabic: isAr, color: bold ? DozColors.textPrimary : DozColors.textMuted)),
      Text(value, style: bold ? DozTextStyles.priceMedium(color: color) : DozTextStyles.bodySmall(isArabic: false, color: color)),
    ]);
  }
}
