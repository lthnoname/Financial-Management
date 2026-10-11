import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.message,
    this.size = 36.0,
    this.color,
  });

  final String? message;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            child: SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? AppColors.primary,
                ),
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 14),
            Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message = 'Đang xử lý...',
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AppLoadingIndicator(
                    size: 32,
                    message: message,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
