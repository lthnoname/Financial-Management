import 'package:material_ui/material_ui.dart';

import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/common/screens/error_screen.dart';
import '../../features/common/screens/loading_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../shared/widgets/app_error_view.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.root: (_) => const LoginScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.loading: (_) => const LoadingScreen(),
        AppRoutes.error: (_) => const ErrorScreen(),
        AppRoutes.dashboard: (_) => const DashboardScreen(),
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

    switch (effectiveName) {
      case AppRoutes.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ForgotPasswordScreen(),
        );

      case AppRoutes.verifyOtp:
        final args = settings.arguments is OtpVerificationArgs
            ? settings.arguments as OtpVerificationArgs
            : const OtpVerificationArgs(username: 'demo_user');
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OtpVerificationScreen(args: args),
        );

      case AppRoutes.resetPassword:
        final username = settings.arguments is String
            ? settings.arguments as String
            : 'demo_user';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ResetPasswordScreen(username: username),
        );

      case AppRoutes.loading:
        final message = settings.arguments is String
            ? settings.arguments as String
            : 'Đang tải dữ liệu...';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => LoadingScreen(message: message),
        );

      case AppRoutes.error:
        final message = settings.arguments is String
            ? settings.arguments as String
            : 'Đã xảy ra sự cố trong quá trình xử lý.';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ErrorScreen(message: message),
        );

      case AppRoutes.dashboard:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DashboardScreen(),
        );

      default:
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
}
