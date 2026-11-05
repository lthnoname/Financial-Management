import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../shared/widgets/app_error_view.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.root: (_) => const LoginScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
      };

  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) {
    return [
      onGenerateRoute(RouteSettings(name: initialRoute)),
    ];
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final effectiveName =
        (settings.name == null || settings.name == AppRoutes.root)
            ? AppRoutes.login
            : settings.name;

    final builder = routes[effectiveName];
    if (builder != null) {
      return MaterialPageRoute(
        settings: settings,
        builder: builder,
      );
    }

    // 404 fallback
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: AppErrorView(
          title: '404 - Page Not Found',
          message: 'The route "${settings.name}" does not exist.',
          retryText: 'Back to Login',
          onRetry: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}
