import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/localization.dart';
import 'services/barrel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LocalizationService>(
          create: (_) => LocalizationService(prefs),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(prefs),
        ),
        ChangeNotifierProvider<VaultService>(
          create: (_) => VaultService(),
        ),
        ChangeNotifierProvider<ProjectService>(
          create: (_) => ProjectService(prefs),
        ),
        ChangeNotifierProvider<ProductTrackingService>(
          create: (_) => ProductTrackingService(prefs),
        ),
      ],
      child: const ElectronicVaultApp(),
    ),
  );
}
