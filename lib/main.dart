import 'package:flutter/material.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const CartkaroDeliveryPartnerApp());
}

/// Root widget of the Cartkaro Delivery Partner app.
class CartkaroDeliveryPartnerApp extends StatelessWidget {
  const CartkaroDeliveryPartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cartkaro Delivery Partner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouter.router,
    );
  }
}