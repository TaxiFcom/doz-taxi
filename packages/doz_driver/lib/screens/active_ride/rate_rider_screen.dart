import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/ride_provider.dart';
import '../../navigation/app_router.dart';

/// Rate rider screen after completing a ride.
class RateRiderScreen extends StatefulWidget {
  const RateRiderScreen({super.key});

  @override
  State<RateRiderScreen> createState() => _RateRiderScreenState();
}

class _RateRiderScreenState extends State<RateRiderScreen> {
  int _stars = 5;
  final Set<String> _selectedTags = {};
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, String>> _tags = [
    {'key': 'polite', 'ar': 'محترم', 'en': 'Polite'},
    {'key': 'onTime', 'ar': 'في الوقت', 'en': 'On Time'},
    {'key': 'cleanPickup', 'ar': 'موقع نظيف', 'en': 'Clean Pickup'},
    {'key': 'friendly', 'ar': 'ودود', 'en': 'Friendly'},
    {'key': 'readyToGo', 'ar': 'مستعد للرحلة', 'en': 'Ready to Go'},
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);
    final ride = context.read<RideProvider>();
    final success = await ride.rateRider(
      stars: _stars,
      tags: _selectedTags.toList(),
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );
    if (success && mounted) {
      context.go(AppRoutes.home);
    } else {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final ride = context.watch<RideProvider>();
    final r = ride.currentRide;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            ride.skipRating();
            context.go(AppRoutes.home);
          },
          icon: const Icon(Icons.close, color: DozColors.textPrimary),
        ),
        title: Text(l.t('rateRider'),
            style: DozTextStyles.sectionTitle(isArabic: isAr)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (r?.rider != null) ...[
              DozAvatar(
                  imageUrl: r!.rider!.avatarUrl, name: r.rider!.name, size: 80),
              const SizedBox(height: 12),
              Text(r.rider!.name,
                  style: DozTextStyles.sectionTitle(isArabic: isAr)),
              const SizedBox(height: 4),
              Text(
                isAr ? 'كيف كانت تجربتك مع الراكب؟' : 'How was your experience?',
                style: DozTextStyles.bodySmall(
                    isArabic: isAr, color: DozColors.textMuted),
              ),
            ],
            const SizedBox(height: 28),
            DozRatingStars(
              rating: _stars.toDouble(),
              starSize: 44,
              interactive: true,
              onRatingChanged: (r) => setState(() => _stars = r),
            ),
            const SizedBox(height: 8),
            Text(_ratingLabel(isAr),
                style: DozTextStyles.labelLarge(
                    isArabic: isAr, color: DozColors.primaryGreen)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _tags.map((tag) {
                final isSelected = _selectedTags.contains(tag['key']);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTags.remove(tag['key']);
                      } else {
                        _selectedTags.add(tag['key']!);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DozColors.primaryGreenSurface
                          : DozColors.cardDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? DozColors.primaryGreen
                            : DozColors.borderDark,
                      ),
                    ),
                    child: Text(
                      isAr ? tag['ar']! : tag['en']!,
                      style: DozTextStyles.bodySmall(
                        isArabic: isAr,
                        color: isSelected
                            ? DozColors.primaryGreen
                            : DozColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            DozTextField(
                controller: _commentController,
                hint: l.t('addComment'),
                maxLines: 3),
            const SizedBox(height: 32),
            DozButton(
                label: l.t('submitRating'),
                loading: _isSubmitting,
                onPressed: _submitRating),
            const SizedBox(height: 12),
            DozButton(
              label: l.t('skipRating'),
              variant: DozButtonVariant.ghost,
              height: 44,
              onPressed: () {
                ride.skipRating();
                context.go(AppRoutes.home);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(bool isAr) {
    switch (_stars) {
      case 5:
        return isAr ? 'ممتاز!' : 'Excellent!';
      case 4:
        return isAr ? 'جيد جداً' : 'Very Good';
      case 3:
        return isAr ? 'جيد' : 'Good';
      case 2:
        return isAr ? 'مقبول' : 'Fair';
      default:
        return isAr ? 'ضعيف' : 'Poor';
    }
  }
}
