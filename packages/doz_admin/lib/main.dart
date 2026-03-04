import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doz_shared/doz_shared.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set browser tab title
  SystemChrome.setApplicationSwitcherDescription(
    const ApplicationSwitcherDescription(
      label: 'DOZ Admin',
      primaryColor: 0xFF7ED321,
    ),
  );

  // Initialize services
  final storage = StorageService.getInstance();
  await storage.init();

  final api = ApiClient.getInstance(storage);

  runApp(DozAdminApp(
    storage: storage,
    api: api,
  ));
}
