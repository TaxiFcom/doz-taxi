import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import 'navigation/app_router.dart';
import 'providers/auth_provider.dart';

/// Root application widget.
/// Handles theme, locale, and navigation.
class DozRiderApp extends StatelessWidget {
  const DozRiderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return MaterialApp.router(
          title: 'DOZ',
          debugShowCheckedModeBanner: false,
          theme: DozTheme.dark,
          darkTheme: DozTheme.dark,
          themeMode: ThemeMode.dark,
          locale: auth.locale,
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
          routerConfig: AppRouter.router(auth),
        );
      },
    );
  }
}
