import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/ride_request/ride_request_screen.dart';
import '../screens/ride_request/place_bid_screen.dart';
import '../screens/active_ride/navigate_to_pickup_screen.dart';
import '../screens/active_ride/at_pickup_screen.dart';
import '../screens/active_ride/in_trip_screen.dart';
import '../screens/active_ride/complete_ride_screen.dart';
import '../screens/active_ride/rate_rider_screen.dart';
import '../screens/rides/rides_history_screen.dart';
import '../screens/rides/ride_detail_screen.dart';
import '../screens/earnings/earnings_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/wallet/withdraw_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/vehicle_info_screen.dart';
import '../screens/profile/documents_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/notifications/notifications_screen.dart';

/// Route name constants.
abstract class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String register = '/register';
  static const String home = '/home';
  static const String rideRequest = '/ride-request';
  static const String placeBid = '/place-bid';
  static const String navigateToPickup = '/navigate-to-pickup';
  static const String atPickup = '/at-pickup';
  static const String inTrip = '/in-trip';
  static const String completeRide = '/complete-ride';
  static const String rateRider = '/rate-rider';
  static const String ridesHistory = '/rides';
  static const String rideDetail = '/rides/:rideId';
  static const String earnings = '/earnings';
  static const String wallet = '/wallet';
  static const String withdraw = '/wallet/withdraw';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String vehicleInfo = '/profile/vehicle';
  static const String documents = '/profile/documents';
  static const String settings = '/profile/settings';
  static const String notifications = '/notifications';
}

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.rideRequest,
        builder: (context, state) => const RideRequestScreen(),
      ),
      GoRoute(
        path: AppRoutes.placeBid,
        builder: (context, state) => const PlaceBidScreen(),
      ),
      GoRoute(
        path: AppRoutes.navigateToPickup,
        builder: (context, state) => const NavigateToPickupScreen(),
      ),
      GoRoute(
        path: AppRoutes.atPickup,
        builder: (context, state) => const AtPickupScreen(),
      ),
      GoRoute(
        path: AppRoutes.inTrip,
        builder: (context, state) => const InTripScreen(),
      ),
      GoRoute(
        path: AppRoutes.completeRide,
        builder: (context, state) => const CompleteRideScreen(),
      ),
      GoRoute(
        path: AppRoutes.rateRider,
        builder: (context, state) => const RateRiderScreen(),
      ),
      GoRoute(
        path: AppRoutes.ridesHistory,
        builder: (context, state) => const RidesHistoryScreen(),
      ),
      GoRoute(
        path: '/rides/:rideId',
        builder: (context, state) => RideDetailScreen(
          rideId: state.pathParameters['rideId'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.earnings,
        builder: (context, state) => const EarningsScreen(),
      ),
      GoRoute(
        path: AppRoutes.wallet,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: AppRoutes.withdraw,
        builder: (context, state) => const WithdrawScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.vehicleInfo,
        builder: (context, state) => const VehicleInfoScreen(),
      ),
      GoRoute(
        path: AppRoutes.documents,
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}
