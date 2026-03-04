import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/ride/confirm_ride_screen.dart';
import '../screens/ride/set_price_screen.dart';
import '../screens/ride/finding_drivers_screen.dart';
import '../screens/ride/bids_screen.dart';
import '../screens/ride/driver_arriving_screen.dart';
import '../screens/ride/in_ride_screen.dart';
import '../screens/ride/ride_complete_screen.dart';
import '../screens/ride/rate_driver_screen.dart';
import '../screens/rides/rides_list_screen.dart';
import '../screens/rides/ride_detail_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/wallet/topup_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/support_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/home/widgets/location_search.dart';

/// Route names as constants.
abstract class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const otp = '/otp';
  static const register = '/register';
  static const home = '/home';
  static const locationSearch = '/location-search';
  static const confirmRide = '/confirm-ride';
  static const setPrice = '/set-price';
  static const findingDrivers = '/finding-drivers';
  static const bids = '/bids';
  static const driverArriving = '/driver-arriving';
  static const inRide = '/in-ride';
  static const rideComplete = '/ride-complete';
  static const rateDriver = '/rate-driver';
  static const rides = '/rides';
  static const rideDetail = '/rides/:id';
  static const wallet = '/wallet';
  static const topup = '/wallet/topup';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const settings = '/settings';
  static const support = '/support';
  static const notifications = '/notifications';
}

/// Central router configuration using go_router.
class AppRouter {
  static GoRouter router(AuthProvider auth) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: false,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, __) => const OnboardingScreen(),
          pageBuilder: (_, state) => _buildPage(
            state,
            const OnboardingScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) => const LoginScreen(),
          pageBuilder: (_, state) => _buildPage(state, const LoginScreen()),
        ),
        GoRoute(
          path: AppRoutes.otp,
          builder: (_, state) {
            final extra = state.extra as Map<String, String>?;
            return OtpScreen(
              phone: extra?['phone'] ?? '',
              countryCode: extra?['countryCode'] ?? '+962',
            );
          },
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (_, state) {
            final extra = state.extra as Map<String, String>?;
            return RegisterScreen(
              phone: extra?['phone'] ?? '',
            );
          },
        ),
        ShellRoute(
          builder: (_, state, child) => child,
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (_, __) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'search',
                  builder: (_, state) {
                    final extra = state.extra as Map<String, dynamic>?;
                    return LocationSearchScreen(
                      isPickup: extra?['isPickup'] as bool? ?? false,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.locationSearch,
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return LocationSearchScreen(
              isPickup: extra?['isPickup'] as bool? ?? false,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.confirmRide,
          builder: (_, __) => const ConfirmRideScreen(),
        ),
        GoRoute(
          path: AppRoutes.setPrice,
          builder: (_, __) => const SetPriceScreen(),
        ),
        GoRoute(
          path: AppRoutes.findingDrivers,
          builder: (_, __) => const FindingDriversScreen(),
        ),
        GoRoute(
          path: AppRoutes.bids,
          builder: (_, __) => const BidsScreen(),
        ),
        GoRoute(
          path: AppRoutes.driverArriving,
          builder: (_, __) => const DriverArrivingScreen(),
        ),
        GoRoute(
          path: AppRoutes.inRide,
          builder: (_, __) => const InRideScreen(),
        ),
        GoRoute(
          path: AppRoutes.rideComplete,
          builder: (_, __) => const RideCompleteScreen(),
        ),
        GoRoute(
          path: AppRoutes.rateDriver,
          builder: (_, state) {
            final rideId = state.extra as String?;
            return RateDriverScreen(rideId: rideId ?? '');
          },
        ),
        GoRoute(
          path: AppRoutes.rides,
          builder: (_, __) => const RidesListScreen(),
        ),
        GoRoute(
          path: '/rides/:id',
          builder: (_, state) => RideDetailScreen(
            rideId: state.pathParameters['id'] ?? '',
          ),
        ),
        GoRoute(
          path: AppRoutes.wallet,
          builder: (_, __) => const WalletScreen(),
        ),
        GoRoute(
          path: AppRoutes.topup,
          builder: (_, __) => const TopUpScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (_, __) => const ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.editProfile,
          builder: (_, __) => const EditProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (_, __) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.support,
          builder: (_, __) => const SupportScreen(),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          builder: (_, __) => const NotificationsScreen(),
        ),
      ],
    );
  }

  static CustomTransitionPage _buildPage(GoRouterState state, Widget child) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, c) {
        return FadeTransition(
          opacity: animation,
          child: c,
        );
      },
    );
  }
}
