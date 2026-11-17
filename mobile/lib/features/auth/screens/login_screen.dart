import 'package:flutter/material.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  String? _usernameError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool _validateForm() {
    // Chế độ demo UI: Cho phép nhập bất cứ ký tự nào để vào thẳng Dashboard
    setState(() {
      _usernameError = null;
      _passwordError = null;
    });
    return true;
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_validateForm()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    debugPrint(
      'Calling API POST /api/v1/auth/login for identifier: $username, password length: ${password.length}',
    );

    setState(() => _isLoading = true);

    // =========================================================================
    // CLIENT - SERVER API INTEGRATION PLACEHOLDER (FR-03)
    // -------------------------------------------------------------------------
    // Endpoint: POST /api/v1/auth/login
    // Request Body: { "identifier": username, "password": password }
    // =========================================================================
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
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
          title: const Text('Login screen'),
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
                      // Brand Logo & Heading
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
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppColors.primary,
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Chào mừng trở lại',
                        style: AppTextStyles.h1,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đăng nhập tài khoản PocketBudget để tiếp tục theo dõi chi tiêu thông minh',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Form Inputs
                      AppTextField(
                        label: 'Tên đăng nhập',
                        hintText: 'Nhập tên đăng nhập của bạn',
                        controller: _usernameController,
                        errorText: _usernameError,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                        prefixIcon: const Icon(
                          Icons.account_circle_outlined,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                        onChanged: (_) {
                          if (_usernameError != null) {
                            setState(() => _usernameError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 18),

                      AppTextField(
                        label: 'Mật khẩu',
                        hintText: 'Nhập mật khẩu của bạn',
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        isPassword: true,
                        errorText: _passwordError,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleLogin(),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                        onChanged: (_) {
                          if (_passwordError != null) {
                            setState(() => _passwordError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      // Forgot Password Link with generous tap target
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(AppRoutes.forgotPassword);
                          },
                          child: Text(
                            'Quên mật khẩu?',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Login Button
                      AppButton(
                        label: 'Đăng nhập',
                        isLoading: _isLoading,
                        size: AppButtonSize.large,
                        icon: Icons.login_rounded,
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 28),

                      // Register Link
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Chưa có tài khoản? ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.register);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                'Đăng ký ngay',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
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
