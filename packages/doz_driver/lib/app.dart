import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:doz_shared/doz_shared.dart';
import 'providers/auth_provider.dart';
import 'providers/driver_provider.dart';
import 'providers/ride_provider.dart';
import 'providers/earnings_provider.dart';
import 'providers/notifications_provider.dart';
import 'navigation/app_router.dart';

class DozDriverApp extends StatefulWidget {
  const DozDriverApp({super.key});

  @override
  State<DozDriverApp> createState() => _DozDriverAppState();
}

class _DozDriverAppState extends State<DozDriverApp> {
  late final StorageService _storage;
  late final ApiClient _api;
  late final AuthService _authService;
  late final WebSocketService _ws;
  late final AuthProvider _authProvider;
  late final DriverProvider _driverProvider;
  late final RideProvider _rideProvider;
  late final EarningsProvider _earningsProvider;
  late final NotificationsProvider _notificationsProvider;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  void _initServices() {
    _storage = StorageService.getInstance();
    _api = ApiClient.getInstance(_storage);
    _authService = AuthService.getInstance(_api, _storage);
    _ws = WebSocketService.getInstance(_storage);

    _authProvider = AuthProvider(
      authService: _authService,
      storage: _storage,
    );
    _driverProvider = DriverProvider(api: _api, ws: _ws);
    _rideProvider = RideProvider(api: _api, ws: _ws);
    _earningsProvider = EarningsProvider(api: _api);
    _notificationsProvider = NotificationsProvider(api: _api);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _driverProvider),
        ChangeNotifierProvider.value(value: _rideProvider),
        ChangeNotifierProvider.value(value: _earningsProvider),
        ChangeNotifierProvider.value(value: _notificationsProvider),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final router = createRouter(context);
          return MaterialApp.router(
            title: 'DOZ Driver',
            debugShowCheckedModeBanner: false,
            theme: DozTheme.dark,
            darkTheme: DozTheme.dark,
            themeMode: ThemeMode.dark,
            locale: Locale(auth.lang),
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: router,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _authProvider.dispose();
    _driverProvider.dispose();
    _rideProvider.dispose();
    _earningsProvider.dispose();
    _notificationsProvider.dispose();
    super.dispose();
  }
}
