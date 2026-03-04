import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/ride_provider.dart';
import '../../providers/bids_provider.dart';
import '../../navigation/app_router.dart';
import '../home/widgets/map_view.dart';
import 'widgets/bid_card.dart';

/// Bids screen — shows incoming driver bids for the current ride.
class BidsScreen extends StatefulWidget {
  const BidsScreen({super.key});

  @override
  State<BidsScreen> createState() => _BidsScreenState();
}

class _BidsScreenState extends State<BidsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ride = context.read<RideProvider>().currentRide;
      if (ride != null) {
        context.read<BidsProvider>().loadBids(ride.id);
      }
    });
  }

  Future<void> _acceptBid(BidModel bid) async {
    final bidsProvider = context.read<BidsProvider>();
    try {
      await bidsProvider.acceptBid(bid.id);
      if (!mounted) return;
      context.go(AppRoutes.driverArriving);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: DozColors.error,
        ),
      );
    }
  }

  Future<void> _rejectBid(BidModel bid) async {
    await context.read<BidsProvider>().rejectBid(bid.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final bidsProvider = context.watch<BidsProvider>();
    final rideProvider = context.watch<RideProvider>();
    final bids = bidsProvider.bids
        .where((b) => b.status == BidStatus.pending)
        .toList();

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      body: Stack(
        children: [
          // Map background
          const MapView(showNearbyDrivers: false),

          // Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (ctx, scrollCtrl) {
              return Container(
                decoration: BoxDecoration(
                  color: DozColors.surfaceDark,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: DozColors.borderDark),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: DozColors.borderDark,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isArabic ? 'العروض الواردة' : 'Incoming Bids',
                                style: DozTextStyles.sectionTitle(
                                    isArabic: isArabic),
                              ),
                              Text(
                                '${bids.length} ${isArabic ? 'عروض' : 'bids'}',
                                style: DozTextStyles.bodySmall(
                                    isArabic: isArabic),
                              ),
                            ],
                          ),

                          // Sort options
                          Row(
                            children: [
                              _SortChip(
                                label: isArabic ? 'السعر' : 'Price',
                                isActive: bidsProvider.sortBy == 'price',
                                onTap: () =>
                                    bidsProvider.setSortBy('price'),
                              ),
                              const SizedBox(width: 8),
                              _SortChip(
                                label: isArabic ? 'التقييم' : 'Rating',
                                isActive: bidsProvider.sortBy == 'rating',
                                onTap: () =>
                                    bidsProvider.setSortBy('rating'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Bid list
                    Expanded(
                      child: bidsProvider.loading && bids.isEmpty
                          ? const Center(child: DozLoading())
                          : bids.isEmpty
                              ? DozEmptyState(
                                  icon: Icons.hourglass_empty_rounded,
                                  title: isArabic
                                      ? 'لا توجد عروض بعد'
                                      : 'No bids yet',
                                  subtitle: isArabic
                                      ? 'السائقون يرسلون عروضهم...'
                                      : 'Drivers are sending their bids...',
                                )
                              : ListView.builder(
                                  controller: scrollCtrl,
                                  itemCount: bids.length,
                                  itemBuilder: (_, i) => BidCard(
                                    bid: bids[i],
                                    suggestedPrice:
                                        rideProvider.offeredPrice ?? 3.0,
                                    onAccept: () => _acceptBid(bids[i]),
                                    onReject: () => _rejectBid(bids[i]),
                                  ),
                                ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Back button
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
                  child: const Icon(Icons.arrow_back_ios_rounded,
                      color: DozColors.textPrimary, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? DozColors.primaryGreen : DozColors.cardDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? DozColors.primaryGreen : DozColors.borderDark,
          ),
        ),
        child: Text(
          label,
          style: DozTextStyles.caption(
            isArabic: isArabic,
            color: isActive ? DozColors.primaryDark : DozColors.textMuted,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
