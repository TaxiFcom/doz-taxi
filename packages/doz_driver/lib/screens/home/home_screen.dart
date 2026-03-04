import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/driver_provider.dart';
import '../../providers/ride_provider.dart';
import '../../providers/earnings_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../navigation/app_router.dart';
import 'widgets/status_toggle.dart';
import 'widgets/earnings_bar.dart';
import 'widgets/new_ride_popup.dart';
import 'widgets/navigation_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initProviders();
      _listenForRideRequests();
    });
  }

  Future<void> _initProviders() async {
    final earnings = context.read<EarningsProvider>();
    earnings.loadTodayEarnings();

    final notifications = context.read<NotificationsProvider>();
    notifications.loadNotifications();
  }

  void _listenForRideRequests() {
    final ws = context.read<RideProvider>();
    ws.startListening();
  }

  @override
  void dispose() {
    context.read<RideProvider>().stopListening();
    super.dispose();
  }

  Widget _buildBody() {
    switch (_selectedTab) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const _RidesTab();
      case 2:
        return const _EarningsTab();
      case 3:
        return const _ProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final rideProvider = context.watch<RideProvider>();
    final driver = context.watch<DriverProvider>();
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;

    return Stack(
      children: [
        // Full-screen map
        const NavigationView(),
        // Top bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const EarningsBar(),
                const Spacer(),
                _notificationButton(context),
              ],
            ),
          ),
        ),
        // Bottom content based on phase
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomContent(rideProvider, driver, l, isAr),
        ),
        // New ride popup
        if (rideProvider.phase == RidePhase.incomingRequest)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: const NewRidePopup(),
          ),
      ],
    );
  }

  Widget _buildBottomContent(
    RideProvider ride,
    DriverProvider driver,
    AppLocalizations l,
    bool isAr,
  ) {
    if (ride.phase == RidePhase.incomingRequest) {
      return const SizedBox.shrink();
    }

    if (ride.phase == RidePhase.waitingAcceptance) {
      return _buildWaitingAcceptance(ride, l, isAr);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, DozColors.primaryDark],
          stops: [0, 0.5],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (driver.isOnline)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: DozColors.primaryGreenSurface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: DozColors.primaryGreen.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _PulsingDot(),
                  const SizedBox(width: 8),
                  Text(
                    isAr ? 'في انتظار الرحلات...' : 'Waiting for rides...',
                    style: DozTextStyles.bodySmall(
                      isArabic: isAr,
                      color: DozColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          const StatusToggle(),
        ],
      ),
    );
  }

  Widget _buildWaitingAcceptance(RideProvider ride, AppLocalizations l, bool isAr) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DozColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DozColors.primaryGreen.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: DozColors.primaryGreen.withOpacity(0.1),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(DozColors.primaryGreen),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isAr ? 'تم تقديم عرضك!' : 'Bid submitted!',
            style: DozTextStyles.sectionTitle(isArabic: isAr),
          ),
          const SizedBox(height: 4),
          Text(
            isAr ? 'في انتظار موافقة الراكب...' : 'Waiting for rider to accept...',
            style: DozTextStyles.bodySmall(isArabic: isAr, color: DozColors.textMuted),
          ),
          if (ride.currentBid != null) ...[
            const SizedBox(height: 12),
            Text(
              DozFormatters.currency(ride.currentBid!.amount),
              style: DozTextStyles.priceLarge(color: DozColors.primaryGreen),
            ),
          ],
          const SizedBox(height: 16),
          DozButton(
            label: isAr ? 'إلغاء العرض' : 'Cancel Bid',
            variant: DozButtonVariant.outlined,
            height: 44,
            onPressed: () => context.read<RideProvider>().cancelBid(),
          ),
        ],
      ),
    );
  }

  Widget _notificationButton(BuildContext context) {
    final notifications = context.watch<NotificationsProvider>();
    return GestureDetector(
      onTap: () => context.push(AppRoutes.notifications),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: DozColors.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DozColors.borderDark),
            ),
            child: const Icon(Icons.notifications_outlined, color: DozColors.textPrimary, size: 22),
          ),
          if (notifications.unreadCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(color: DozColors.error, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '${notifications.unreadCount}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      extendBody: true,
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: DozColors.navDark,
          border: const Border(top: BorderSide(color: DozColors.borderDark, width: 1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _navItem(0, Icons.home_outlined, Icons.home, l.t('home'), isAr),
                _navItem(1, Icons.history_outlined, Icons.history, l.t('rideHistory'), isAr),
                _navItem(2, Icons.attach_money_outlined, Icons.attach_money, l.t('earnings'), isAr),
                _navItem(3, Icons.person_outline, Icons.person, l.t('profile'), isAr),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label, bool isAr) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, color: isSelected ? DozColors.primaryGreen : DozColors.textMuted, size: 24),
            const SizedBox(height: 4),
            Text(label, style: DozTextStyles.caption(isArabic: isAr, color: isSelected ? DozColors.primaryGreen : DozColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.6, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: DozColors.primaryGreen, shape: BoxShape.circle)),
    );
  }
}

class _RidesTab extends StatelessWidget {
  const _RidesTab();
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) { context.push(AppRoutes.ridesHistory); });
    return const Center(child: DozLoading());
  }
}

class _EarningsTab extends StatelessWidget {
  const _EarningsTab();
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) { context.push(AppRoutes.earnings); });
    return const Center(child: DozLoading());
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) { context.push(AppRoutes.profile); });
    return const Center(child: DozLoading());
  }
}
