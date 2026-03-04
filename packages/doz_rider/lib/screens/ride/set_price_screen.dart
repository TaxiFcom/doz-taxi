import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/ride_provider.dart';
import '../../navigation/app_router.dart';

/// Set price screen — rider suggests a price using +/- controls.
class SetPriceScreen extends StatefulWidget {
  const SetPriceScreen({super.key});

  @override
  State<SetPriceScreen> createState() => _SetPriceScreenState();
}

class _SetPriceScreenState extends State<SetPriceScreen> {
  late double _price;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _price = context.read<RideProvider>().offeredPrice ?? 3.0;
  }

  Future<void> _confirmRide() async {
    final rideProvider = context.read<RideProvider>();
    final pickup = rideProvider.pickup;
    final dropoff = rideProvider.dropoff;

    if (pickup == null || dropoff == null) return;

    setState(() => _loading = true);
    try {
      await rideProvider.createRide(
        pickupLat: pickup.lat,
        pickupLng: pickup.lng,
        pickupAddress: pickup.address,
        dropoffLat: dropoff.lat,
        dropoffLng: dropoff.lng,
        dropoffAddress: dropoff.address,
        suggestedPrice: _price,
        vehicleType: rideProvider.selectedVehicleType ?? 'economy',
      );
      if (!mounted) return;
      context.go(AppRoutes.findingDrivers);
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final rideProvider = context.watch<RideProvider>();

    final minPrice = AppConstants.minRidePrice;
    final maxPrice = AppConstants.maxRidePrice;
    final suggested = rideProvider.offeredPrice ?? 3.0;

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
          isArabic ? 'اختر سعرك' : 'Set Your Price',
          style: DozTextStyles.sectionTitle(isArabic: isArabic),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: DozColors.darkGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // Selected vehicle info
                if (rideProvider.vehicleTypes.isNotEmpty) ...[
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: DozColors.cardDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: DozColors.borderDark),
                      ),
                      child: Text(
                        isArabic
                            ? rideProvider.vehicleTypes
                                    .firstWhere(
                                      (v) =>
                                          v.id ==
                                          (rideProvider.selectedVehicleType ??
                                              'economy'),
                                      orElse: () => rideProvider.vehicleTypes.first,
                                    )
                                    .nameAr
                            : rideProvider.vehicleTypes
                                .firstWhere(
                                  (v) =>
                                      v.id ==
                                      (rideProvider.selectedVehicleType ??
                                          'economy'),
                                  orElse: () => rideProvider.vehicleTypes.first,
                                )
                                .nameEn,
                        style: DozTextStyles.bodyMedium(isArabic: isArabic),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Suggested price hint
                Center(
                  child: Text(
                    '${isArabic ? 'السعر المقترح: ' : 'Suggested: '}${suggested.toStringAsFixed(3)} JOD',
                    style: DozTextStyles.bodyMedium(
                      isArabic: isArabic,
                      color: DozColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Price input with +/- controls
                DozPriceInput(
                  initialValue: _price,
                  minValue: minPrice,
                  maxValue: maxPrice,
                  step: 0.5,
                  onChanged: (v) {
                    setState(() => _price = v);
                    rideProvider.setOfferedPrice(v);
                  },
                ),

                const SizedBox(height: 16),

                // Price range hint
                Center(
                  child: Text(
                    isArabic
                        ? 'المدى: $minPrice - $maxPrice JOD'
                        : 'Range: $minPrice - $maxPrice JOD',
                    style: DozTextStyles.caption(isArabic: isArabic),
                  ),
                ),

                const Spacer(flex: 2),

                // Confirm button
                DozButton(
                  label: isArabic ? 'تأكيد وإرسال الطلب' : 'Confirm & Send',
                  onPressed: _loading ? null : _confirmRide,
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
