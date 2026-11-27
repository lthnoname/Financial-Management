import 'package:material_ui/material_ui.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.username,
  });

  final String username;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _confirmFocus = FocusNode();

  String? _newPasswordError;
  String? _confirmPasswordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    bool isValid = true;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      if (newPassword.isEmpty) {
        _newPasswordError = 'Vui lòng nhập mật khẩu mới';
        isValid = false;
      } else if (newPassword.length < 6) {
        _newPasswordError = 'Mật khẩu phải có ít nhất 6 ký tự';
        isValid = false;
      } else {
        _newPasswordError = null;
      }

      if (confirmPassword.isEmpty) {
        _confirmPasswordError = 'Vui lòng xác nhận lại mật khẩu mới';
        isValid = false;
      } else if (confirmPassword != newPassword) {
        _confirmPasswordError = 'Mật khẩu xác nhận không khớp';
        isValid = false;
      } else {
        _confirmPasswordError = null;
      }
    });

    return isValid;
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    final newPassword = _newPasswordController.text;
    debugPrint(
      'Calling API POST /api/v1/auth/reset-password for ${widget.username} (pass len: ${newPassword.length})',
    );

    setState(() => _isLoading = true);

    // =========================================================================
    // CLIENT - SERVER API INTEGRATION PLACEHOLDER (FR-04)
    // -------------------------------------------------------------------------
    // Endpoint: POST /api/v1/auth/reset-password
    // Request Body: { "identifier": username, "newPassword": newPassword }
    // =========================================================================
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.success,
        content: Text('Đặt lại mật khẩu thành công! Vui lòng đăng nhập lại.'),
      ),
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Đặt lại mật khẩu'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 20,
                vertical: 16,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
                  decoration: isWide
                      ? BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        )
                      : null,
                  padding: EdgeInsets.all(isWide ? 32 : 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Brand Icon
                      Center(
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.password_rounded,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Tạo mật khẩu mới',
                        style: AppTextStyles.h1,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Thiết lập mật khẩu an toàn mới cho tài khoản:',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.username,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Mật khẩu mới
                      AppTextField(
                        label: 'Mật khẩu mới',
                        hintText: 'Tối thiểu 6 ký tự',
                        controller: _newPasswordController,
                        isPassword: true,
                        errorText: _newPasswordError,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _confirmFocus.requestFocus(),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                        onChanged: (_) {
                          if (_newPasswordError != null) {
                            setState(() => _newPasswordError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 18),

                      // Xác nhận mật khẩu mới
                      AppTextField(
                        label: 'Xác nhận mật khẩu mới',
                        hintText: 'Nhập lại mật khẩu mới vừa nhập',
                        controller: _confirmPasswordController,
                        focusNode: _confirmFocus,
                        isPassword: true,
                        errorText: _confirmPasswordError,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleSubmit(),
                        prefixIcon: const Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                        onChanged: (_) {
                          if (_confirmPasswordError != null) {
                            setState(() => _confirmPasswordError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      AppButton(
                        label: 'Cập nhật mật khẩu',
                        isLoading: _isLoading,
                        size: AppButtonSize.large,
                        icon: Icons.check_circle_rounded,
                        onPressed: _handleSubmit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
