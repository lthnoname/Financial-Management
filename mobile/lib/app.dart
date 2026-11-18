import 'package:material_ui/material_ui.dart';

import 'core/routing/routing.dart';
import 'features/dashboard/dashboard_screen.dart';

class FinanceApp extends StatelessWidget {
  final String? initialRoute;

  const FinanceApp({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Management',
      debugShowCheckedModeBanner: false,
      theme: pocketTheme(),
      initialRoute: initialRoute ?? AppRoutes.dashboard,
      routes: AppRouter.routes,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onGenerateInitialRoutes: AppRouter.onGenerateInitialRoutes,
    );
  }
}
