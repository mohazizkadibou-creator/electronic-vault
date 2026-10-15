import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/localization.dart';
import 'ui/screens/home_screen.dart';

class ElectronicVaultApp extends StatelessWidget {
  const ElectronicVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LocalizationService l10n = context.watch<LocalizationService>();

    return MaterialApp(
      title: l10n.strings.t('appTitle'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2A4B7C)),
        useMaterial3: true,
      ),
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection:
              l10n.strings.isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomeScreen(),
    );
  }
}
