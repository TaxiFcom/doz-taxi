import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ride_provider.dart';
import '../../providers/location_provider.dart';
import '../../navigation/app_router.dart';
import 'widgets/map_view.dart';
import 'widgets/bottom_drawer.dart';

/// Main home screen — full-screen map with search and navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final DraggableScrollableController _drawerController =
      DraggableScrollableController();
  bool _isDrawerExpanded = false;

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.map_outlined,
      activeIcon: Icons.map_rounded,
      labelKey: 'home',
    ),
    _NavItem(
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
      labelKey: 'myRides',
    ),
    _NavItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      labelKey: 'wallet',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      labelKey: 'profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().requestPermission().then((_) {
        context.read<LocationProvider>().getCurrentLocation();
      });
      context.read<RideProvider>().loadVehicleTypes();
    });
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex && index == 0) return;

    switch (index) {
      case 1:
        context.push(AppRoutes.rides);
        break;
      case 2:
        context.push(AppRoutes.wallet);
        break;
      case 3:
        context.push(AppRoutes.profile);
        break;
      default:
        setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      body: Stack(
        children: [
          // Full-screen map
          const MapView(),

          // Top bar (menu + notification)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Menu icon
                  _TopBarButton(
                    icon: Icons.menu_rounded,
                    onTap: () => context.push(AppRoutes.profile),
                  ),

                  // Greeting
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) {
                      final name = auth.user?.name.split(' ').first ?? '';
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: DozColors.cardDark.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: DozColors.borderDark),
                        ),
                        child: Text(
                          isArabic ? 'مرحباً $name' : 'Hi $name',
                          style: DozTextStyles.bodyMedium(isArabic: isArabic),
                        ),
                      );
                    },
                  ),

                  // Notification bell
                  _TopBarButton(
                    icon: Icons.notifications_outlined,
                    onTap: () => context.push(AppRoutes.notifications),
                  ),
                ],
              ),
            ),
          ),

          // My location FAB
          Positioned(
            right: 16,
            bottom: 200,
            child: _LocationFab(),
          ),

          // Bottom drawer with "Where to?" and recent locations
          HomeBottomDrawer(
            controller: _drawerController,
            onSearchTap: () {
              context.push(
                AppRoutes.locationSearch,
                extra: {'isPickup': false},
              );
            },
          ),
        ],
      ),

      // Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: DozColors.navDark,
          border: Border(
            top: BorderSide(color: DozColors.borderDark, width: 0.5),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(
                _navItems.length,
                (i) => Expanded(
                  child: _NavBarItem(
                    item: _navItems[i],
                    isActive: i == _selectedIndex,
                    onTap: () => _onNavTap(i),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopBarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: DozColors.cardDark.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DozColors.borderDark),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: DozColors.textPrimary, size: 22),
      ),
    );
  }
}

class _LocationFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<LocationProvider>().getCurrentLocation();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: DozColors.cardDark,
          shape: BoxShape.circle,
          border: Border.all(color: DozColors.borderDark),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.my_location_rounded,
          color: DozColors.primaryGreen,
          size: 22,
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String labelKey;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
  });
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    // Map label keys
    final labels = {
      'home': {'ar': 'الرئيسية', 'en': 'Home'},
      'myRides': {'ar': 'رحلاتي', 'en': 'Rides'},
      'wallet': {'ar': 'المحفظة', 'en': 'Wallet'},
      'profile': {'ar': 'حسابي', 'en': 'Profile'},
    };

    final label =
        (labels[item.labelKey] ?? {})[isArabic ? 'ar' : 'en'] ?? item.labelKey;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isActive ? item.activeIcon : item.icon,
              key: ValueKey(isActive),
              color: isActive ? DozColors.primaryGreen : DozColors.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: DozTextStyles.caption(
              isArabic: isArabic,
              color: isActive ? DozColors.primaryGreen : DozColors.textMuted,
            ).copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

