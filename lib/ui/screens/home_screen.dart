import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/barrel.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

/// Root screen: shows the login flow until the user is authenticated,
/// then the project dashboard.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = context.watch<AuthService>().isLoggedIn;
    return isLoggedIn ? const DashboardScreen() : const LoginScreen();
  }
}
