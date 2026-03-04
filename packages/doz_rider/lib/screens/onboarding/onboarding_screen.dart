import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../navigation/app_router.dart';

/// Onboarding screen with 3 pages showing DOZ features.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    const _OnboardingPage(
      icon: Icons.location_on_rounded,
      titleAr: 'حدد وجهتك',
      titleEn: 'Set Your Destination',
      subtitleAr: 'حدد مكان انطلاقك ووجهتك بسهولة على الخريطة',
      subtitleEn: 'Easily set your pickup and destination on the map',
      iconColor: DozColors.primaryGreen,
      gradient: [Color(0xFF1A1A2E), Color(0xFF0D3B1A)],
    ),
    const _OnboardingPage(
      icon: Icons.gavel_rounded,
      titleAr: 'تفاوض على السعر',
      titleEn: 'Negotiate Your Price',
      subtitleAr: 'أنت تحدد السعر الذي تريده والسائقون يتقدمون بعروضهم',
      subtitleEn: 'You set the price you want and drivers bid for your ride',
      iconColor: DozColors.info,
      gradient: [Color(0xFF1A1A2E), Color(0xFF0D1A3B)],
    ),
    const _OnboardingPage(
      icon: Icons.navigation_rounded,
      titleAr: 'تتبع رحلتك',
      titleEn: 'Track Your Ride',
      subtitleAr: 'تابع موقع السائق في الوقت الفعلي من الاستلام حتى الوصول',
      subtitleEn: 'Track your driver in real-time from pickup to destination',
      iconColor: DozColors.warning,
      gradient: [Color(0xFF1A1A2E), Color(0xFF3B2A0D)],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.login);
    }
  }

  void _skip() {
    context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _OnboardingPageView(page: _pages[i]),
          ),
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    l10n.t('skip'),
                    style: DozTextStyles.bodyMedium(
                      isArabic: isArabic,
                      color: DozColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: i == _currentPage
                                ? DozColors.primaryGreen
                                : DozColors.borderDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    DozButton(
                      label: isLastPage
                          ? (isArabic ? 'ابدأ الآن' : 'Get Started')
                          : l10n.t('next'),
                      onPressed: _nextPage,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String titleAr;
  final String titleEn;
  final String subtitleAr;
  final String subtitleEn;
  final Color iconColor;
  final List<Color> gradient;

  const _OnboardingPage({
    required this.icon,
    required this.titleAr,
    required this.titleEn,
    required this.subtitleAr,
    required this.subtitleEn,
    required this.iconColor,
    required this.gradient,
  });
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: page.gradient,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: page.iconColor.withOpacity(0.1),
                border: Border.all(
                  color: page.iconColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: page.iconColor.withOpacity(0.15),
                  ),
                  child: Icon(page.icon, size: 64, color: page.iconColor),
                ),
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Text(
                    isArabic ? page.titleAr : page.titleEn,
                    style: DozTextStyles.pageTitle(isArabic: isArabic),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isArabic ? page.subtitleAr : page.subtitleEn,
                    style: DozTextStyles.bodyLarge(
                      isArabic: isArabic,
                      color: DozColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
