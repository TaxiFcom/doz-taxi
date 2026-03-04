import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../models/location_model.dart';
import '../../providers/ride_provider.dart';
import '../../navigation/app_router.dart';
import '../home/widgets/map_view.dart';
import 'widgets/vehicle_type_card.dart';
import 'widgets/route_summary.dart';

/// Confirm ride screen — shows route on map, vehicle type selection.
class ConfirmRideScreen extends StatefulWidget {
  const ConfirmRideScreen({super.key});

  @override
  State<ConfirmRideScreen> createState() => _ConfirmRideScreenState();
}

class _ConfirmRideScreenState extends State<ConfirmRideScreen> {
  String _selectedType = 'economy';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().loadVehicleTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final rideProvider = context.watch<RideProvider>();
    final pickup = rideProvider.pickup;
    final dropoff = rideProvider.dropoff;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      body: Stack(
        children: [
          // Map with route
          MapView(
            pickupPoint: pickup != null
                ? LatLng(pickup.lat, pickup.lng)
                : null,
            dropoffPoint: dropoff != null
                ? LatLng(dropoff.lat, dropoff.lng)
                : null,
            showRoute: true,
            showNearbyDrivers: false,
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: DozColors.cardDark.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DozColors.borderDark),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: DozColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          // Bottom panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: DozColors.surfaceDark,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: DozColors.borderDark),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: DozColors.borderDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Route summary
                  if (pickup != null && dropoff != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RouteSummary(
                        pickupAddress: isArabic
                            ? pickup.address
                            : pickup.addressEn ?? pickup.address,
                        dropoffAddress: isArabic
                            ? dropoff.address
                            : dropoff.addressEn ?? dropoff.address,
                        distanceKm: rideProvider.currentRide?.distanceKm,
                        durationMin: rideProvider.currentRide?.durationMin,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Vehicle type selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        isArabic ? 'نوع السيارة' : 'Vehicle Type',
                        style: DozTextStyles.labelLarge(isArabic: isArabic),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 110,
                    child: rideProvider.vehicleTypes.isEmpty
                        ? const Center(child: DozLoading())
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: rideProvider.vehicleTypes.length,
                            itemBuilder: (_, i) {
                              final vt = rideProvider.vehicleTypes[i];
                              return VehicleTypeCard(
                                vehicleType: vt,
                                isSelected: _selectedType == vt.id,
                                onTap: () {
                                  setState(() => _selectedType = vt.id);
                                  rideProvider.setVehicleType(vt.id);
                                },
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DozButton(
                      label: isArabic ? 'اختر سعرك' : 'Set Your Price',
                      onPressed: () {
                        rideProvider.setVehicleType(_selectedType);
                        context.push(AppRoutes.setPrice);
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
