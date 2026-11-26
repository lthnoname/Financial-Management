import 'package:material_ui/material_ui.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_error_view.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    this.title = 'Đã có lỗi xảy ra',
    this.message = 'Không thể kết nối tới máy chủ. Vui lòng thử lại sau.',
    this.retryText = 'Thử lại',
    this.onRetry,
    this.showBackToLogin = true,
  });

  final String title;
  final String message;
  final String retryText;
  final VoidCallback? onRetry;
  final bool showBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thông báo sự cố'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tái sử dụng AppErrorView từ shared widgets
                AppErrorView(
                  title: title,
                  message: message,
                  retryText: retryText,
                  onRetry: onRetry,
                ),
                if (showBackToLogin) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AppButton(
                      label: 'Quay về Đăng nhập',
                      variant: AppButtonVariant.outlined,
                      icon: Icons.arrow_back_rounded,
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
