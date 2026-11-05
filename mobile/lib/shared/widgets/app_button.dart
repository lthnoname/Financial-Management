import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  danger,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = true,
    this.icon,
    this.isTrailingIcon = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final IconData? icon;
  final bool isTrailingIcon;

  bool get _canPress => !isLoading && !isDisabled && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final edgeInsets = _padding;
    final textStyle = _textStyle;
    final colors = _colors;

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          RepaintBoundary(
            child: SizedBox(
              width: _spinnerSize,
              height: _spinnerSize,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.foreground),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null && !isTrailingIcon) ...[
          Icon(icon, size: _iconSize, color: colors.foreground),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: textStyle.copyWith(color: colors.foreground),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!isLoading && icon != null && isTrailingIcon) ...[
          const SizedBox(width: 8),
          Icon(icon, size: _iconSize, color: colors.foreground),
        ],
      ],
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: colors.borderSide,
    );

    Widget button;
    switch (variant) {
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: _canPress ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: colors.foreground,
            disabledForegroundColor: AppColors.disabledText,
            padding: edgeInsets,
            shape: buttonShape,
          ),
          child: content,
        );
        break;
      case AppButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: _canPress ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.foreground,
            disabledForegroundColor: AppColors.disabledText,
            padding: edgeInsets,
            side: colors.borderSide,
            shape: buttonShape,
          ),
          child: content,
        );
        break;
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
      case AppButtonVariant.danger:
        button = ElevatedButton(
          onPressed: _canPress ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.background,
            foregroundColor: colors.foreground,
            disabledBackgroundColor: AppColors.disabled,
            disabledForegroundColor: AppColors.disabledText,
            elevation: 0,
            padding: edgeInsets,
            shape: buttonShape,
          ),
          child: content,
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  EdgeInsets get _padding {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 18);
    }
  }

  TextStyle get _textStyle {
    switch (size) {
      case AppButtonSize.small:
        return AppTextStyles.button.copyWith(fontSize: 13);
      case AppButtonSize.medium:
        return AppTextStyles.button.copyWith(fontSize: 15);
      case AppButtonSize.large:
        return AppTextStyles.button.copyWith(fontSize: 16);
    }
  }

  double get _spinnerSize {
    switch (size) {
      case AppButtonSize.small:
        return 14;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 20;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 19;
      case AppButtonSize.large:
        return 22;
    }
  }

  _ButtonColors get _colors {
    if (!_canPress) {
      return _ButtonColors(
        background: AppColors.disabled,
        foreground: AppColors.disabledText,
        borderSide: BorderSide.none,
      );
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return _ButtonColors(
          background: AppColors.primary,
          foreground: AppColors.textOnPrimary,
          borderSide: BorderSide.none,
        );
      case AppButtonVariant.secondary:
        return _ButtonColors(
          background: AppColors.secondary,
          foreground: AppColors.textOnPrimary,
          borderSide: BorderSide.none,
        );
      case AppButtonVariant.outlined:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: AppColors.primary,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        );
      case AppButtonVariant.text:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: AppColors.primary,
          borderSide: BorderSide.none,
        );
      case AppButtonVariant.danger:
        return _ButtonColors(
          background: AppColors.expense,
          foreground: AppColors.textOnPrimary,
          borderSide: BorderSide.none,
        );
    }
  }
}

class _ButtonColors {
  _ButtonColors({
    required this.background,
    required this.foreground,
    required this.borderSide,
  });

  final Color background;
  final Color foreground;
  final BorderSide borderSide;
}
