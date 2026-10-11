import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.isRequired = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.maxLines = 1,
  });

  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final bool isRequired;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final int maxLines;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.enabled
                      ? AppColors.textPrimary
                      : AppColors.disabledText,
                ),
              ),
              if (widget.isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          style: AppTextStyles.bodyMedium.copyWith(
            color: widget.enabled
                ? AppColors.textPrimary
                : AppColors.disabledText,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: widget.prefixIcon,
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: _toggleObscure,
                  )
                : widget.suffixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: widget.suffixIcon,
                      )
                    : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
          ),
        ),
      ],
    );
  }
}
