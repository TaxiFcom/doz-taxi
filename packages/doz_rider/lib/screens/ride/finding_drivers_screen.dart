import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/ride_provider.dart';
import '../../providers/bids_provider.dart';
import '../../navigation/app_router.dart';
import '../home/widgets/map_view.dart';

/// Finding drivers screen — pulsing animation while searching.
class FindingDriversScreen extends StatefulWidget {
  const FindingDriversScreen({super.key});

  @override
  State<FindingDriversScreen> createState() => _FindingDriversScreenState();
}

class _FindingDriversScreenState extends State<FindingDriversScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulse1, _pulse2, _pulse3;
  int _elapsedSeconds = 0;
  Timer? _timer;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulse1 = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _pulse2 = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
      ),
    );
    _pulse3 = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Elapsed timer
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _elapsedSeconds++);
    });

    // Poll for bids
    _startPolling();
  }

  void _startPolling() {
    final ride = context.read<RideProvider>().currentRide;
    if (ride == null) return;

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final bidsProvider = context.read<BidsProvider>();
      bidsProvider.loadBids(ride.id).then((_) {
        if (!mounted) return;
        if (bidsProvider.pendingCount > 0) {
          _pollTimer?.cancel();
          context.go(AppRoutes.bids);
        }
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  String _formatElapsed() {
    final min = _elapsedSeconds ~/ 60;
    final sec = _elapsedSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  Future<void> _cancelRide() async {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DozColors.cardDark,
        title: Text(
          isArabic ? 'إلغاء البحث' : 'Cancel Search',
          style: DozTextStyles.sectionTitle(isArabic: isArabic),
        ),
        content: Text(
          isArabic
              ? 'هل تريد إلغاء البحث عن سائق؟'
              : 'Do you want to cancel searching for a driver?',
          style: DozTextStyles.bodyMedium(isArabic: isArabic),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.t('no'),
              style: const TextStyle(color: DozColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.t('yes'),
              style: const TextStyle(color: DozColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<RideProvider>().cancelRide(
            reason: isArabic ? 'إلغاء من قبل الراكب' : 'Cancelled by rider',
          );
      if (!mounted) return;
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final ride = context.watch<RideProvider>().currentRide;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      body: Stack(
        children: [
          // Map background
          const MapView(showNearbyDrivers: false),

          // Overlay
          Container(color: DozColors.scrim),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Timer
                  Center(
                    child: Text(
                      _formatElapsed(),
                      style: DozTextStyles.mono(
                        size: 20,
                        color: DozColors.textMuted,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Pulsing animation
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (_, __) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulse rings
                              _PulseRing(
                                size: 180,
                                opacity: _pulse3.value * 0.2,
                              ),
                              _PulseRing(
                                size: 130,
                                opacity: _pulse2.value * 0.3,
                              ),
                              _PulseRing(
                                size: 80,
                                opacity: _pulse1.value * 0.4,
                              ),

                              // Center dot
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: DozColors.primaryGreen,
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: DozColors.primaryDark,
                                  size: 22,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    isArabic ? 'جاري البحث عن سائق...' : 'Looking for drivers...',
                    style: DozTextStyles.pageTitle(isArabic: isArabic),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  if (ride != null)
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
                          '${isArabic ? 'سعرك: ' : 'Your fare: '}${ride.suggestedPrice.toStringAsFixed(3)} JOD',
                          style: DozTextStyles.bodyMedium(
                            isArabic: isArabic,
                            color: DozColors.primaryGreen,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                  const Spacer(),

                  // Cancel button
                  DozButton(
                    label: l10n.t('cancel'),
                    onPressed: _cancelRide,
                    variant: DozButtonVariant.outlined,
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  final double size;
  final double opacity;

  const _PulseRing({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: DozColors.primaryGreen.withOpacity(opacity),
          width: 2,
        ),
      ),
    );
  }
}
