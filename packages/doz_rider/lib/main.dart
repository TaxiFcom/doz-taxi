import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import 'providers/auth_provider.dart';
import 'providers/ride_provider.dart';
import 'providers/bids_provider.dart';
import 'providers/location_provider.dart';
import 'providers/wallet_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: DozColors.navDark,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize services
  final storage = StorageService.getInstance();
  await storage.init();

  final api = ApiClient.getInstance(storage);
  final authService = AuthService.getInstance(api, storage);

  // Read saved locale
  final savedLocale = await storage.getLanguage() ?? 'ar';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            api: api,
            storage: storage,
            authService: authService,
            initialLocale: savedLocale,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RideProvider(api: api),
        ),
        ChangeNotifierProvider(
          create: (_) => BidsProvider(api: api),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletProvider(api: api),
        ),
      ],
      child: const DozRiderApp(),
    ),
  );
}
