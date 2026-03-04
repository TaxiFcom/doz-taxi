import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/ride_provider.dart';
import '../../navigation/app_router.dart';

/// Rate driver screen — star rating, quick tags, tip, and comment.
class RateDriverScreen extends StatefulWidget {
  final String rideId;

  const RateDriverScreen({super.key, required this.rideId});

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  int _rating = 0;
  final Set<String> _selectedTags = {};
  double? _tipAmount;
  final _commentController = TextEditingController();
  bool _loading = false;

  final List<Map<String, String>> _tags = [
    {'ar': 'خدمة ممتازة', 'en': 'Great Service'},
    {'ar': 'سيارة نظيفة', 'en': 'Clean Car'},
    {'ar': 'قيادة سليمة', 'en': 'Good Driving'},
    {'ar': 'ودود', 'en': 'Friendly'},
    {'ar': 'دقيق في المواعيد', 'en': 'On Time'},
  ];

  final List<double> _tipOptions = [0.5, 1.0, 2.0];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.isArabic
                ? 'يرجى اختيار تقييم'
                : 'Please select a rating',
          ),
          backgroundColor: DozColors.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      // TODO: submit rating via API
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      context.read<RideProvider>().clearCurrentRide();
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: DozColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final ride = context.watch<RideProvider>().currentRide;
    final driver = ride?.driver;
    final name = driver?.user?.name ?? (isArabic ? 'السائق' : 'Driver');

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: DozColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            context.read<RideProvider>().clearCurrentRide();
            context.go(AppRoutes.home);
          },
          color: DozColors.textPrimary,
        ),
        title: Text(
          isArabic ? 'قيّم رحلتك' : 'Rate Your Ride',
          style: DozTextStyles.sectionTitle(isArabic: isArabic),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: DozColors.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Driver info
                Center(
                  child: Column(
                    children: [
                      DozAvatar(
                        imageUrl: driver?.user?.avatarUrl,
                        name: name,
                        size: 80,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: DozTextStyles.sectionTitle(isArabic: isArabic),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic
                            ? 'كيف كانت تجربتك مع $name؟'
                            : 'How was your ride with $name?',
                        style: DozTextStyles.bodyMedium(
                          isArabic: isArabic,
                          color: DozColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Star rating
                DozRatingPicker(
                  onRatingSelected: (r) => setState(() => _rating = r),
                  initialRating: _rating,
                  starSize: 52,
                ),

                const SizedBox(height: 28),

                // Quick tags
                Text(
                  isArabic ? 'ما أعجبك في الرحلة؟' : 'What did you like?',
                  style: DozTextStyles.labelLarge(isArabic: isArabic),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tags.map((tag) {
                    final label = isArabic ? tag['ar']! : tag['en']!;
                    final isSelected = _selectedTags.contains(label);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedTags.remove(label);
                          } else {
                            _selectedTags.add(label);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
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
                          label,
                          style: DozTextStyles.bodySmall(
                            isArabic: isArabic,
                            color: isSelected
                                ? DozColors.primaryGreen
                                : DozColors.textSecondary,
                          ).copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Tip selection
                Text(
                  isArabic ? 'إضافة إكرامية (اختياري)' : 'Add a Tip (Optional)',
                  style: DozTextStyles.labelLarge(isArabic: isArabic),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // No tip option
                    _TipOption(
                      label: isArabic ? 'لا' : 'None',
                      isSelected: _tipAmount == null,
                      onTap: () => setState(() => _tipAmount = null),
                    ),
                    const SizedBox(width: 8),
                    ..._tipOptions.map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _TipOption(
                          label: '${tip.toStringAsFixed(2)} JOD',
                          isSelected: _tipAmount == tip,
                          onTap: () => setState(() => _tipAmount = tip),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Comment field
                DozTextField(
                  controller: _commentController,
                  label:
                      '${isArabic ? 'تعليق' : 'Comment'} (${l10n.t('optional')})',
                  hint: isArabic
                      ? 'أضف تعليقاً إن أردت...'
                      : 'Add a comment (optional)',
                  maxLines: 3,
                ),

                const SizedBox(height: 32),

                // Submit button
                DozButton(
                  label: isArabic ? 'إرسال التقييم' : 'Submit Rating',
                  onPressed: _loading ? null : _submitRating,
                  loading: _loading,
                ),

                const SizedBox(height: 12),

                DozButton(
                  label: isArabic ? 'تخطي' : 'Skip',
                  onPressed: () {
                    context.read<RideProvider>().clearCurrentRide();
                    context.go(AppRoutes.home);
                  },
                  variant: DozButtonVariant.ghost,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TipOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TipOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? DozColors.primaryGreenSurface : DozColors.cardDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? DozColors.primaryGreen : DozColors.borderDark,
          ),
        ),
        child: Text(
          label,
          style: DozTextStyles.bodySmall(
            isArabic: isArabic,
            color: isSelected
                ? DozColors.primaryGreen
                : DozColors.textSecondary,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
