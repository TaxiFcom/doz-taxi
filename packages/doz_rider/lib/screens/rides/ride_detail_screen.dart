import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/ride_provider.dart';

/// Detailed view of a single ride.
class RideDetailScreen extends StatefulWidget {
  final String rideId;

  const RideDetailScreen({super.key, required this.rideId});

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  RideModel? _ride;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRide();
  }

  Future<void> _loadRide() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ride =
          await context.read<RideProvider>().getRideDetail(widget.rideId);
      setState(() {
        _ride = ride;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
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
          isArabic ? 'تفاصيل الرحلة' : 'Ride Details',
          style: DozTextStyles.sectionTitle(isArabic: isArabic),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: DozLoading())
          : _error != null
              ? DozErrorState(message: _error!, onRetry: _loadRide)
              : _ride == null
                  ? DozEmptyState(
                      icon: Icons.receipt_long_rounded,
                      title: isArabic ? 'الرحلة غير موجودة' : 'Ride not found',
                    )
                  : _buildContent(context, _ride!),
    );
  }

  Widget _buildContent(BuildContext context, RideModel ride) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final total = ride.finalPrice ?? ride.suggestedPrice;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status + date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DozStatusBadge.ride(ride.status, context: context),
              Text(
                DozFormatters.date(ride.createdAt,
                    lang: isArabic ? 'ar' : 'en'),
                style: DozTextStyles.bodySmall(isArabic: isArabic),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Route card
          DozCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'المسار' : 'Route',
                  style: DozTextStyles.labelLarge(isArabic: isArabic),
                ),
                const SizedBox(height: 12),
                _AddressRow(
                  icon: Icons.location_on_rounded,
                  color: DozColors.mapPickup,
                  label: isArabic ? 'الانطلاق' : 'Pickup',
                  address: ride.pickupAddress,
                ),
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    width: 2,
                    height: 20,
                    color: DozColors.borderDark),
                _AddressRow(
                  icon: Icons.location_on_rounded,
                  color: DozColors.mapDropoff,
                  label: isArabic ? 'الوصول' : 'Dropoff',
                  address: ride.dropoffAddress,
                ),
                if (ride.distanceKm != null || ride.durationMin != null) ...[
                  Divider(height: 16, color: DozColors.borderDark),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (ride.distanceKm != null)
                        _InfoChip(
                          icon: Icons.straighten_rounded,
                          label: DozFormatters.distance(ride.distanceKm!,
                              lang: isArabic ? 'ar' : 'en'),
                        ),
                      if (ride.durationMin != null)
                        _InfoChip(
                          icon: Icons.access_time_rounded,
                          label: DozFormatters.duration(ride.durationMin!,
                              lang: isArabic ? 'ar' : 'en'),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Fare breakdown
          DozCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isArabic ? 'تفاصيل الأجرة' : 'Fare Breakdown',
                  style: DozTextStyles.labelLarge(isArabic: isArabic),
                ),
                const SizedBox(height: 12),
                _FareRow(
                  label: isArabic ? 'الأجرة المقترحة' : 'Suggested Fare',
                  amount: ride.suggestedPrice,
                ),
                if (ride.finalPrice != null)
                  _FareRow(
                    label: isArabic ? 'الأجرة النهائية' : 'Final Fare',
                    amount: ride.finalPrice!,
                    highlight: true,
                  ),
                Divider(height: 16, color: DozColors.borderDark),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isArabic ? 'المدفوع' : 'Paid',
                      style: DozTextStyles.sectionTitle(isArabic: isArabic),
                    ),
                    DozPriceTag(amount: total),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Driver info
          if (ride.driver != null) ...[
            DozCard(
              child: Row(
                children: [
                  DozAvatar(
                    imageUrl: ride.driver!.user?.avatarUrl,
                    name: ride.driver!.user?.name ?? '',
                    size: 52,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.driver!.user?.name ?? '',
                          style: DozTextStyles.sectionTitle(isArabic: isArabic),
                        ),
                        const SizedBox(height: 4),
                        DozRatingStars(
                          rating: ride.driver!.rating,
                          starSize: 14,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ride.driver!.vehicleModel} · ${ride.driver!.plateNumber}',
                          style: DozTextStyles.caption(isArabic: isArabic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Report issue
          DozButton(
            label: isArabic ? 'الإبلاغ عن مشكلة' : 'Report an Issue',
            onPressed: () {
              // TODO: open issue report
            },
            variant: DozButtonVariant.outlined,
            prefixIcon: const Icon(Icons.flag_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String address;

  const _AddressRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: DozTextStyles.caption(isArabic: isArabic),
              ),
              Text(
                address,
                style: DozTextStyles.bodySmall(isArabic: isArabic)
                    .copyWith(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: DozColors.textMuted, size: 14),
        const SizedBox(width: 4),
        Text(label, style: DozTextStyles.caption(isArabic: isArabic)),
      ],
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool highlight;

  const _FareRow({
    required this.label,
    required this.amount,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: DozTextStyles.bodyMedium(
              isArabic: isArabic,
              color: highlight ? DozColors.textPrimary : DozColors.textMuted,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(3)} JOD',
            style: DozTextStyles.bodyMedium(isArabic: false)
                .copyWith(
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
              color: highlight ? DozColors.primaryGreen : DozColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
