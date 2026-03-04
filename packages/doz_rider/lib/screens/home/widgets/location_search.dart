import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../../models/location_model.dart';
import '../../../providers/ride_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../navigation/app_router.dart';

/// Full-screen location search overlay.
/// Used for selecting pickup or dropoff location.
class LocationSearchScreen extends StatefulWidget {
  final bool isPickup;

  const LocationSearchScreen({super.key, required this.isPickup});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<_SearchResult> _results = [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged() async {
    final query = _searchController.text.trim();
    if (query.length < 2) {
      setState(() {
        _results = [];
        _searching = false;
      });
      return;
    }

    setState(() => _searching = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted || _searchController.text.trim() != query) return;

    setState(() {
      _results = [
        _SearchResult(
          icon: Icons.location_on_rounded,
          name: query,
          nameEn: query,
          address: 'عمّان، الأردن',
          addressEn: 'Amman, Jordan',
          lat: 31.9539 + (query.length * 0.001),
          lng: 35.9106 + (query.length * 0.001),
        ),
        _SearchResult(
          icon: Icons.location_on_rounded,
          name: '$query - المركز',
          nameEn: '$query - Center',
          address: 'وسط البلد، عمّان',
          addressEn: 'Downtown, Amman',
          lat: 31.9520,
          lng: 35.9300,
        ),
      ];
      _searching = false;
    });
  }

  void _selectLocation(_SearchResult result) {
    final rideProvider = context.read<RideProvider>();
    final location = LocationModel(
      lat: result.lat,
      lng: result.lng,
      address: result.name,
      addressEn: result.nameEn,
    );

    if (widget.isPickup) {
      rideProvider.setPickupLocation(location);
    } else {
      rideProvider.setDropoffLocation(location);
    }

    if (!widget.isPickup && rideProvider.pickup != null) {
      context.go(AppRoutes.confirmRide);
    } else if (!widget.isPickup) {
      final locationProv = context.read<LocationProvider>();
      rideProvider.setPickupLocation(LocationModel(
        lat: locationProv.latLng?.latitude ?? 31.9539,
        lng: locationProv.latLng?.longitude ?? 35.9106,
        address: 'موقعي الحالي',
        addressEn: 'My Current Location',
      ));
      context.go(AppRoutes.confirmRide);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final hasQuery = _searchController.text.isNotEmpty;
    final displayResults = hasQuery ? _results : <_SearchResult>[];

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              color: DozColors.surfaceDark,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: DozColors.textPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: DozColors.cardDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DozColors.borderDark),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.search_rounded,
                              color: DozColors.textMuted,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              style: DozTextStyles.bodyMedium(isArabic: isArabic),
                              decoration: InputDecoration(
                                hintText: isArabic
                                    ? (widget.isPickup ? 'أدخل موقع الانطلاق' : 'إلى أين؟')
                                    : (widget.isPickup ? 'Enter pickup location' : 'Where to?'),
                                hintStyle: DozTextStyles.bodyMedium(
                                  isArabic: isArabic,
                                  color: DozColors.textMuted,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (hasQuery)
                            GestureDetector(
                              onTap: () => _searchController.clear(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: DozColors.textMuted,
                                  size: 18,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DozColors.primaryGreenSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: DozColors.primaryGreen,
                  size: 20,
                ),
              ),
              title: Text(
                isArabic ? 'موقعي الحالي' : 'My Current Location',
                style: DozTextStyles.bodyMedium(isArabic: isArabic)
                    .copyWith(color: DozColors.primaryGreen),
              ),
              subtitle: Text(
                isArabic ? 'استخدام GPS' : 'Using GPS',
                style: DozTextStyles.caption(isArabic: isArabic),
              ),
              onTap: () {
                final locProv = context.read<LocationProvider>();
                final rideProvider = context.read<RideProvider>();
                final location = LocationModel(
                  lat: locProv.latLng?.latitude ?? 31.9539,
                  lng: locProv.latLng?.longitude ?? 35.9106,
                  address: 'موقعي الحالي',
                  addressEn: 'My Current Location',
                );
                if (widget.isPickup) {
                  rideProvider.setPickupLocation(location);
                  context.pop();
                } else {
                  rideProvider.setPickupLocation(location);
                  rideProvider.setDropoffLocation(location);
                  context.go(AppRoutes.confirmRide);
                }
              },
            ),
            Divider(height: 1, color: DozColors.borderDark, indent: 20, endIndent: 20),
            if (!hasQuery)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    isArabic ? 'البحث الأخير' : 'Recent Searches',
                    style: DozTextStyles.labelLarge(isArabic: isArabic),
                  ),
                ),
              ),
            if (_searching)
              const Expanded(child: Center(child: DozLoading()))
            else if (displayResults.isEmpty)
              Expanded(
                child: DozEmptyState(
                  icon: Icons.search_rounded,
                  title: isArabic ? 'ابحث عن موقع' : 'Search for a location',
                  subtitle: isArabic ? 'اكتب اسم المكان للبحث' : 'Type a location name to search',
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: displayResults.length,
                  itemBuilder: (_, i) {
                    final r = displayResults[i];
                    return _SearchResultItem(
                      result: r,
                      onTap: () => _selectLocation(r),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchResult {
  final IconData icon;
  final String name;
  final String nameEn;
  final String address;
  final String addressEn;
  final double lat;
  final double lng;

  const _SearchResult({
    required this.icon,
    required this.name,
    required this.nameEn,
    required this.address,
    required this.addressEn,
    required this.lat,
    required this.lng,
  });
}

class _SearchResultItem extends StatelessWidget {
  final _SearchResult result;
  final VoidCallback onTap;

  const _SearchResultItem({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: DozColors.cardDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DozColors.borderDark),
        ),
        child: Icon(result.icon, color: DozColors.textMuted, size: 20),
      ),
      title: Text(
        isArabic ? result.name : result.nameEn,
        style: DozTextStyles.bodyMedium(isArabic: isArabic).copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        isArabic ? result.address : result.addressEn,
        style: DozTextStyles.caption(isArabic: isArabic),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
