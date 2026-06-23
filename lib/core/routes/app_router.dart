import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/delivery_partner_registration_screen.dart';
import '../constants/app_colors.dart';

/// Centralized GoRouter configuration for the app.
class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String registration =
      '/delivery-partner-registration-screen';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,

    routes: [

      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) =>
            const SplashScreen(),
      ),


      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) =>
            const LoginScreen(),
      ),


      GoRoute(
        path: registration,
        name: 'registration',
        builder: (context, state) {

          final mobile =
              state.extra as String? ?? '';

          return DeliveryPartnerRegistrationScreen(
            mobileNumber: mobile,
          );
        },
      ),


      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) =>
            const _PlaceholderScreen(
              title: 'Dashboard',
            ),
      ),
    ],

    errorBuilder: (context, state) =>
        const _PlaceholderScreen(
          title: 'Page Not Found',
        ),
  );
}


/// Temporary dashboard placeholder
class _PlaceholderScreen extends StatelessWidget {

  final String title;

  const _PlaceholderScreen({
    required this.title,
  });


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.background,

      body: Center(

        child: Text(
          '$title Screen\n(Coming Soon)',

          textAlign: TextAlign.center,

          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}