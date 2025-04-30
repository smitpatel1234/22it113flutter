import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/operator/operator_dashboard.dart';
import 'screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartFab Costing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        // Add implicit animations as default transitions
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Show splash screen while checking authentication
          if (authProvider.isLoading) {
            return const SplashScreen();
          }

          // If authenticated, route based on role
          if (authProvider.isAuthenticated) {
            if (authProvider.isAdmin) {
              return const AdminDashboard();
            } else {
              return const OperatorDashboard();
            }
          }

          // Not authenticated, show login
          return const LoginScreen();
        },
      ),
    );
  }
}
