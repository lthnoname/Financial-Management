import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    this.title = 'Đã có lỗi xảy ra',
    required this.message,
    this.onRetry,
    this.retryText = 'Thử lại',
    this.icon = Icons.error_outline_rounded,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              AppButton(
                label: retryText,
                variant: AppButtonVariant.primary,
                size: AppButtonSize.medium,
                isFullWidth: false,
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
  });

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.error,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
