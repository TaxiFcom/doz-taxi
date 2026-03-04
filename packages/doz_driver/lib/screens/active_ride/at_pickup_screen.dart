import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/ride_provider.dart';
import '../../navigation/app_router.dart';

/// At pickup screen — driver has arrived, waiting for rider.
class AtPickupScreen extends StatefulWidget {
  const AtPickupScreen({super.key});

  @override
  State<AtPickupScreen> createState() => _AtPickupScreenState();
}

class _AtPickupScreenState extends State<AtPickupScreen> {
  Timer? _waitTimer;
  int _waitSeconds = 0;

  @override
  void initState() {
    super.initState();
    _waitTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _waitSeconds++);
    });
  }

  @override
  void dispose() {
    _waitTimer?.cancel();
    super.dispose();
  }

  String get _waitDuration {
    final m = _waitSeconds ~/ 60;
    final s = _waitSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final rideProvider = context.watch<RideProvider>();
    final r = rideProvider.currentRide;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: DozColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: DozColors.primaryDark,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.t('arrivedAtPickup'),
                      style: DozTextStyles.sectionTitle(isArabic: isAr)
                          .copyWith(color: DozColors.primaryDark),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      r?.pickupAddress ?? '',
                      style: DozTextStyles.bodySmall(isArabic: isAr)
                          .copyWith(color: DozColors.primaryDark.withOpacity(0.7)),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (r?.rider != null)
                DozCard(
                  child: Row(
                    children: [
                      DozAvatar(
                        imageUrl: r!.rider!.avatarUrl,
                        name: r.rider!.name,
                        size: 56,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.rider!.name,
                              style: DozTextStyles.sectionTitle(isArabic: isAr),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text('4.8',
                                    style: DozTextStyles.caption(isArabic: false)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final phone = r.rider?.phone;
                          if (phone != null) launchUrl(Uri.parse('tel:$phone'));
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: DozColors.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.phone,
                            color: DozColors.success,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              DozCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? 'وقت الانتظار' : 'Waiting time',
                      style: DozTextStyles.bodyMedium(isArabic: isAr),
                    ),
                    Text(
                      _waitDuration,
                      style: DozTextStyles.priceMedium(
                          color: _waitSeconds > 300
                              ? DozColors.error
                              : DozColors.primaryGreen),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              DozButton(
                label: l.t('startRide'),
                loading: rideProvider.isLoading,
                onPressed: () async {
                  final ok = await rideProvider.startRide();
                  if (ok && context.mounted) {
                    context.pushReplacement(AppRoutes.inTrip);
                  }
                },
              ),
              const SizedBox(height: 12),
              DozButton(
                label: l.t('cancelRide'),
                variant: DozButtonVariant.ghost,
                height: 44,
                onPressed: () => _showCancelDialog(context, rideProvider, l, isAr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(
    BuildContext context,
    RideProvider ride,
    AppLocalizations l,
    bool isAr,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DozColors.cardDark,
        title: Text(l.t('cancelRide'),
            style: DozTextStyles.sectionTitle(isArabic: isAr)),
        content: Text(l.t('confirmCancelRide'),
            style: DozTextStyles.bodyMedium(isArabic: isAr)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.t('no'),
                style: DozTextStyles.buttonSmall(
                    isArabic: isAr, color: DozColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ride.cancelCurrentRide();
              if (context.mounted) context.go(AppRoutes.home);
            },
            child: Text(l.t('yes'),
                style: DozTextStyles.buttonSmall(
                    isArabic: isAr, color: DozColors.error)),
          ),
        ],
      ),
    );
  }
}
