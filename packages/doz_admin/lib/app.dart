import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/rides_provider.dart';
import 'providers/users_provider.dart';
import 'providers/drivers_provider.dart';
import 'providers/payments_provider.dart';
import 'providers/settings_provider.dart';
import 'navigation/app_router.dart';

/// Root application widget for DOZ Admin Dashboard.
class DozAdminApp extends StatelessWidget {
  final StorageService storage;
  final ApiClient api;

  const DozAdminApp({
    super.key,
    required this.storage,
    required this.api,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core services
        Provider<StorageService>.value(value: storage),
        Provider<ApiClient>.value(value: api),

        // Auth provider (must come before router)
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(api: api, storage: storage),
        ),

        // Feature providers
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => DashboardProvider(api: api),
        ),
        ChangeNotifierProvider<RidesProvider>(
          create: (_) => RidesProvider(api: api),
        ),
        ChangeNotifierProvider<UsersProvider>(
          create: (_) => UsersProvider(api: api),
        ),
        ChangeNotifierProvider<DriversProvider>(
          create: (_) => DriversProvider(api: api),
        ),
        ChangeNotifierProvider<PaymentsProvider>(
          create: (_) => PaymentsProvider(api: api),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(storage: storage),
        ),
      ],
      child: const _AppWithRouter(),
    );
  }
}

class _AppWithRouter extends StatefulWidget {
  const _AppWithRouter();

  @override
  State<_AppWithRouter> createState() => _AppWithRouterState();
}

class _AppWithRouterState extends State<_AppWithRouter> {
  late GoRouter _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router = AppRouter.createRouter(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DOZ Admin',
      debugShowCheckedModeBanner: false,
      theme: DozTheme.light,
      themeMode: ThemeMode.light,
      locale: const Locale('en'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}
