import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

enum OtpMode {
  register,
  forgotPassword,
}

class OtpVerificationArgs {
  const OtpVerificationArgs({
    required this.username,
    this.mode = OtpMode.register,
  });

  final String username;
  final OtpMode mode;
}

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.args,
  });

  final OtpVerificationArgs args;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _otpLength = 6;
  static const String _demoOtp = '123456';

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  int _resendCountdown = 60;
  Timer? _countdownTimer;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(
      _otpLength,
      (index) => FocusNode(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            if (_controllers[index].text.isEmpty && index > 0) {
              _controllers[index - 1].clear();
              _focusNodes[index - 1].requestFocus();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
      ),
    );
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }

    if (value.length > 1) {
      // Handles pasting full OTP
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final nextFocus =
          digits.length < _otpLength ? digits.length : _otpLength - 1;
      _focusNodes[nextFocus].requestFocus();
      return;
    }

    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _fillDemoOtp() {
    for (int i = 0; i < _otpLength; i++) {
      _controllers[i].text = _demoOtp[i];
    }
    setState(() => _errorMessage = null);
    _focusNodes.last.unfocus();
  }

  Future<void> _handleVerify() async {
    FocusScope.of(context).unfocus();
    final code = _currentOtp;
    if (code.length < _otpLength) {
      setState(() {
        _errorMessage = 'Vui lòng nhập đầy đủ $_otpLength chữ số OTP';
      });
      return;
    }

    setState(() => _isLoading = true);

    debugPrint(
      'Calling API POST /api/v1/auth/verify-otp for identifier: ${widget.args.username}, otp: $code',
    );

    // =========================================================================
    // CLIENT - SERVER API INTEGRATION PLACEHOLDER (FR-02)
    // -------------------------------------------------------------------------
    // Endpoint: POST /api/v1/auth/verify-otp
    // Request Body: { "identifier": username, "otp": code }
    // =========================================================================
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (widget.args.mode == OtpMode.register) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text('Xác thực tài khoản thành công! Vui lòng đăng nhập.'),
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } else {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.resetPassword,
        arguments: widget.args.username,
      );
    }
  }

  Future<void> _handleResend() async {
    if (_resendCountdown > 0) return;

    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    _startCountdown();

    debugPrint(
      'Calling API to resend OTP for identifier: ${widget.args.username}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã gửi lại mã OTP cho tài khoản "${widget.args.username}"',
        ),
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
          title: const Text('Xác thực OTP'),
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
                      // Security Icon with Squircle background
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
                            Icons.mark_email_read_outlined,
                            color: AppColors.primary,
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Nhập mã xác thực',
                        style: AppTextStyles.h1,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mã xác thực gồm 6 số đã được gửi tới tài khoản:',
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
                            widget.args.username,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Responsive 6-digit OTP Input Fields
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final totalWidth = constraints.maxWidth;
                          const gap = 8.0;
                          final boxWidth = ((totalWidth - (gap * (_otpLength - 1))) /
                                  _otpLength)
                              .clamp(38.0, 52.0);

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_otpLength, (index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index < _otpLength - 1 ? gap : 0,
                                ),
                                child: SizedBox(
                                  width: boxWidth,
                                  height: boxWidth * 1.2,
                                  child: TextField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.h2.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLength: 1,
                                    decoration: InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.zero,
                                      filled: true,
                                      fillColor: _controllers[index].text.isNotEmpty
                                          ? AppColors.primaryContainer
                                              .withValues(alpha: 0.3)
                                          : AppColors.surface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: AppColors.border,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                          color: _errorMessage != null
                                              ? AppColors.error
                                              : AppColors.border,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                    onChanged: (val) =>
                                        _onDigitChanged(index, val),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),

                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _errorMessage!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Demo Helper Quick Fill Chip
                      Center(
                        child: ActionChip(
                          avatar: const Icon(
                            Icons.bolt_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          label: const Text('Điền mã test nhanh: 123456'),
                          onPressed: _fillDemoOtp,
                          backgroundColor:
                              AppColors.primaryContainer.withValues(alpha: 0.4),
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Resend Countdown
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            _resendCountdown > 0
                                ? 'Gửi lại mã sau (${_resendCountdown}s)'
                                : 'Chưa nhận được mã? ',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (_resendCountdown == 0)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _handleResend,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                child: Text(
                                  'Gửi lại ngay',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Verify Button
                      AppButton(
                        label: 'Xác thực OTP',
                        isLoading: _isLoading,
                        size: AppButtonSize.large,
                        icon: Icons.verified_user_outlined,
                        onPressed: _handleVerify,
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
