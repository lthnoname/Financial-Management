import 'package:material_ui/material_ui.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  String? _fullNameError;
  String? _usernameError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  bool _validateForm() {
    bool isValid = true;
    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      if (fullName.isEmpty) {
        _fullNameError = 'Vui lòng nhập họ và tên';
        isValid = false;
      } else {
        _fullNameError = null;
      }

      if (username.isEmpty) {
        _usernameError = 'Vui lòng nhập tên đăng nhập';
        isValid = false;
      } else if (username.length < 3) {
        _usernameError = 'Tên đăng nhập tối thiểu 3 ký tự';
        isValid = false;
      } else if (username.contains(' ')) {
        _usernameError = 'Tên đăng nhập không được chứa khoảng trắng';
        isValid = false;
      } else {
        _usernameError = null;
      }

      if (password.isEmpty) {
        _passwordError = 'Vui lòng nhập mật khẩu';
        isValid = false;
      } else if (password.length < 6) {
        _passwordError = 'Mật khẩu phải từ 6 ký tự trở lên';
        isValid = false;
      } else {
        _passwordError = null;
      }

      if (confirmPassword.isEmpty) {
        _confirmPasswordError = 'Vui lòng xác nhận mật khẩu';
        isValid = false;
      } else if (confirmPassword != password) {
        _confirmPasswordError = 'Mật khẩu xác nhận không khớp';
        isValid = false;
      } else {
        _confirmPasswordError = null;
      }
    });

    return isValid;
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    if (!_validateForm()) return;

    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    debugPrint(
      'Calling API POST /api/v1/auth/register for $fullName ($username, pass len: ${password.length})',
    );

    setState(() => _isLoading = true);

    // =========================================================================
    // CLIENT - SERVER API INTEGRATION PLACEHOLDER (FR-01)
    // -------------------------------------------------------------------------
    // Endpoint: POST /api/v1/auth/register
    // Request Body: { "fullName": fullName, "identifier": username, "password": password }
    // =========================================================================
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushNamed(
      AppRoutes.verifyOtp,
      arguments: OtpVerificationArgs(
        username: username,
        mode: OtpMode.register,
      ),
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
          title: const Text('Đăng ký tài khoản'),
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
                            Icons.person_add_alt_1_rounded,
                            color: AppColors.primary,
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Tạo tài khoản mới',
                        style: AppTextStyles.h1,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bắt đầu làm chủ tài chính cá nhân với PocketBudget',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // Họ và tên
                      AppTextField(
                        label: 'Họ và tên',
                        hintText: 'Ví dụ: Nguyễn Văn An',
                        controller: _fullNameController,
                        errorText: _fullNameError,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _usernameFocus.requestFocus(),
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                        onChanged: (_) {
                          if (_fullNameError != null) {
                            setState(() => _fullNameError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tên đăng nhập (username)
                      AppTextField(
                        label: 'Tên đăng nhập',
                        hintText: 'Ví dụ: nguyenvanan',
                        controller: _usernameController,
                        focusNode: _usernameFocus,
                        errorText: _usernameError,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
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
                      const SizedBox(height: 16),

                      // Mật khẩu
                      AppTextField(
                        label: 'Mật khẩu',
                        hintText: 'Tối thiểu 6 ký tự',
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        isPassword: true,
                        errorText: _passwordError,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) =>
                            _confirmPasswordFocus.requestFocus(),
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
                      const SizedBox(height: 16),

                      // Xác nhận mật khẩu
                      AppTextField(
                        label: 'Xác nhận mật khẩu',
                        hintText: 'Nhập lại mật khẩu vừa nhập',
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocus,
                        isPassword: true,
                        errorText: _confirmPasswordError,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleRegister(),
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
                      const SizedBox(height: 26),

                      // Register Button
                      AppButton(
                        label: 'Đăng ký ngay',
                        isLoading: _isLoading,
                        size: AppButtonSize.large,
                        icon: Icons.check_circle_outline_rounded,
                        onPressed: _handleRegister,
                      ),
                      const SizedBox(height: 24),

                      // Link back to Login
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Đã có tài khoản? ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => Navigator.of(context).pop(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                'Đăng nhập',
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
