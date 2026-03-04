import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/rides/rides_screen.dart';
import '../screens/users/riders_screen.dart';
import '../screens/users/drivers_screen.dart';
import '../screens/payments/payments_screen.dart';
import '../screens/payments/revenue_report_screen.dart';
import '../screens/vehicles/vehicle_types_screen.dart';
import '../screens/promos/promo_codes_screen.dart';
import '../screens/support/tickets_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return GoRouter(
      initialLocation: '/dashboard',
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final isLoginRoute = state.matchedLocation == '/login';
        if (!isLoggedIn && !isLoginRoute) return '/login';
        if (isLoggedIn && isLoginRoute) return '/dashboard';
        return null;
      },
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/rides',
          name: 'rides',
          builder: (context, state) => const RidesScreen(),
        ),
        GoRoute(
          path: '/riders',
          name: 'riders',
          builder: (context, state) => const RidersScreen(),
        ),
        GoRoute(
          path: '/drivers',
          name: 'drivers',
          builder: (context, state) => const DriversScreen(),
        ),
        GoRoute(
          path: '/payments',
          name: 'payments',
          builder: (context, state) => const PaymentsScreen(),
        ),
        GoRoute(
          path: '/revenue',
          name: 'revenue',
          builder: (context, state) => const RevenueReportScreen(),
        ),
        GoRoute(
          path: '/vehicle-types',
          name: 'vehicle-types',
          builder: (context, state) => const VehicleTypesScreen(),
        ),
        GoRoute(
          path: '/promo-codes',
          name: 'promo-codes',
          builder: (context, state) => const PromoCodesScreen(),
        ),
        GoRoute(
          path: '/support',
          name: 'support',
          builder: (context, state) => const TicketsScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }
}

/// Navigation items for the sidebar.
class NavItem {
  final String route;
  final String labelKey;
  final IconData icon;
  final IconData activeIcon;

  const NavItem({
    required this.route,
    required this.labelKey,
    required this.icon,
    required this.activeIcon,
  });
}

const List<NavItem> kNavItems = [
  NavItem(
    route: '/dashboard',
    labelKey: 'dashboard',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard,
  ),
  NavItem(
    route: '/rides',
    labelKey: 'rides',
    icon: Icons.directions_car_outlined,
    activeIcon: Icons.directions_car,
  ),
  NavItem(
    route: '/riders',
    labelKey: 'riders',
    icon: Icons.people_outline,
    activeIcon: Icons.people,
  ),
  NavItem(
    route: '/drivers',
    labelKey: 'drivers',
    icon: Icons.drive_eta_outlined,
    activeIcon: Icons.drive_eta,
  ),
  NavItem(
    route: '/payments',
    labelKey: 'payments',
    icon: Icons.payment_outlined,
    activeIcon: Icons.payment,
  ),
  NavItem(
    route: '/revenue',
    labelKey: 'revenueReport',
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart,
  ),
  NavItem(
    route: '/vehicle-types',
    labelKey: 'vehicleTypes',
    icon: Icons.commute_outlined,
    activeIcon: Icons.commute,
  ),
  NavItem(
    route: '/promo-codes',
    labelKey: 'promoCodes',
    icon: Icons.local_offer_outlined,
    activeIcon: Icons.local_offer,
  ),
  NavItem(
    route: '/support',
    labelKey: 'support',
    icon: Icons.help_outline,
    activeIcon: Icons.help,
  ),
  NavItem(
    route: '/settings',
    labelKey: 'settings',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings,
  ),
];
