import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_button.dart';

enum AppDialogType {
  info,
  success,
  warning,
  error,
}

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = AppDialogType.info,
    this.confirmText = 'Xác nhận',
    this.cancelText = 'Hủy',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.customContent,
  });

  final String title;
  final String message;
  final AppDialogType type;
  final String confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final Widget? customContent;

  static Future<bool?> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Xác nhận',
    String cancelText = 'Hủy',
    bool isDestructive = false,
    AppDialogType type = AppDialogType.warning,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AppDialog(
        title: title,
        message: message,
        type: type,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  static Future<void> showAlert(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Đồng ý',
    AppDialogType type = AppDialogType.info,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AppDialog(
        title: title,
        message: message,
        type: type,
        confirmText: confirmText,
        cancelText: null,
        onConfirm: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Tuyệt vời',
  }) {
    return showAlert(
      context,
      title: title,
      message: message,
      type: AppDialogType.success,
      confirmText: confirmText,
    );
  }

  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Đã hiểu',
  }) {
    return showAlert(
      context,
      title: title,
      message: message,
      type: AppDialogType.error,
      confirmText: confirmText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = _typeMeta;

    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: meta.bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                meta.icon,
                color: meta.iconColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              title,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            if (customContent != null) ...[
              const SizedBox(height: 16),
              customContent!,
            ],

            const SizedBox(height: 24),

            // Action Buttons
            if (cancelText != null)
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: cancelText!,
                      variant: AppButtonVariant.outlined,
                      size: AppButtonSize.medium,
                      isFullWidth: true,
                      onPressed: onCancel ?? () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: confirmText,
                      variant: isDestructive
                          ? AppButtonVariant.danger
                          : AppButtonVariant.primary,
                      size: AppButtonSize.medium,
                      isFullWidth: true,
                      onPressed: onConfirm ?? () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              )
            else
              AppButton(
                label: confirmText,
                variant: AppButtonVariant.primary,
                size: AppButtonSize.medium,
                isFullWidth: true,
                onPressed: onConfirm ?? () => Navigator.of(context).pop(),
              ),
          ],
        ),
      ),
    );
  }

  _DialogMeta get _typeMeta {
    switch (type) {
      case AppDialogType.info:
        return _DialogMeta(
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.info,
          bgColor: AppColors.infoLight,
        );
      case AppDialogType.success:
        return _DialogMeta(
          icon: Icons.check_circle_outline_rounded,
          iconColor: AppColors.success,
          bgColor: AppColors.incomeLight,
        );
      case AppDialogType.warning:
        return _DialogMeta(
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.warning,
          bgColor: AppColors.warningLight,
        );
      case AppDialogType.error:
        return _DialogMeta(
          icon: Icons.error_outline_rounded,
          iconColor: AppColors.error,
          bgColor: AppColors.errorLight,
        );
    }
  }
}

class _DialogMeta {
  _DialogMeta({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
}
