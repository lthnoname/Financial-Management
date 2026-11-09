import 'package:flutter/material.dart';

import 'core/routing/routing.dart';
import 'features/dashboard/dashboard_screen.dart';

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Management',
      debugShowCheckedModeBanner: false,
      theme: pocketTheme(),
      initialRoute: AppRoutes.dashboard,
      routes: AppRouter.routes,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onGenerateInitialRoutes: AppRouter.onGenerateInitialRoutes,
    );
  }
}
