package com.example.backend.auth;

import com.example.backend.common.AuthException;
import com.example.backend.user.User;
import com.example.backend.user.UserRepository;

import java.security.SecureRandom;
import java.time.LocalDateTime;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

    private final UserRepository userRepository;
    private final OtpTokenRepository otpTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final SecureRandom secureRandom = new SecureRandom();

    private static final int MAX_OTP_ATTEMPTS = 5;
    private static final int OTP_EXPIRY_MINUTES = 10;
    private static final int OTP_RESEND_COOLDOWN_SECONDS = 60;

    public AuthService(
            UserRepository userRepository,
            OtpTokenRepository otpTokenRepository,
            PasswordEncoder passwordEncoder
    ) {
        this.userRepository = userRepository;
        this.otpTokenRepository = otpTokenRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public RegisterResponse register(RegisterRequest request) {
        String normalizedIdentifier = normalizeIdentifier(request.getIdentifier());

        if (userRepository.existsByIdentifier(normalizedIdentifier)) {
            throw new AuthException(HttpStatus.CONFLICT, "Người dùng đã tồn tại");
        }

        User user = new User(
                normalizedIdentifier,
                passwordEncoder.encode(request.getPassword()),
                request.getFullName().trim(),
                true
        );

        User savedUser = userRepository.save(user);

        createOtp(savedUser, OtpToken.Purpose.VERIFY_ACCOUNT);

        return new RegisterResponse(
                savedUser.getId(),
                savedUser.getVerificationRequired(),
                "Đăng ký thành công. Vui lòng xác thực mã OTP."
        );
    }

    @Transactional
    public VerifyOtpResponse verifyOtp(VerifyOtpRequest request) {
        String identifier = normalizeIdentifier(request.identifier());

        userRepository.findByIdentifier(identifier).orElseThrow(() -> new AuthException(
                HttpStatus.BAD_REQUEST, "OTP không hợp lệ"
        ));

        OtpToken token = otpTokenRepository
                .findTopByUserIdentifierAndPurposeAndUsedFalseOrderByCreatedAtDesc(
                        identifier, OtpToken.Purpose.VERIFY_ACCOUNT
                )
                .orElseThrow(() -> new AuthException(
                        HttpStatus.BAD_REQUEST, "OTP không hợp lệ"
                ));

        if (token.isExpired()) {
            throw new AuthException(HttpStatus.GONE, "Mã OTP đã hết hạn");
        }

        if (token.getAttemptCount() >= MAX_OTP_ATTEMPTS) {
            throw new AuthException(
                    HttpStatus.BAD_REQUEST,
                    "Bạn đã nhập sai OTP quá số lần cho phép"
            );
        }

        if (!token.getOtpCode().equals(request.otp())) {
            token.increaseAttempt();
            otpTokenRepository.save(token);
            throw new AuthException(HttpStatus.BAD_REQUEST, "OTP không chính xác");
        }

        token.markUsed();
        User user = userRepository.findByIdentifier(identifier).orElseThrow();
        user.setVerificationRequired(false);
        otpTokenRepository.save(token);
        userRepository.save(user);

        return new VerifyOtpResponse(true, "Xác thực tài khoản thành công.");
    }

    @Transactional
    public MessageResponse forgotPassword(ForgotPasswordRequest request) {
        String identifier = normalizeIdentifier(request.identifier());
        User user = userRepository.findByIdentifier(identifier).orElseThrow(() ->
                new AuthException(HttpStatus.NOT_FOUND, "Không tìm thấy tài khoản")
        );

        LocalDateTime cooldownTime = LocalDateTime.now()
                .minusSeconds(OTP_RESEND_COOLDOWN_SECONDS);

        if (otpTokenRepository.existsByUserIdentifierAndPurposeAndCreatedAtAfter(
                identifier, OtpToken.Purpose.RESET_PASSWORD, cooldownTime
        )) {
            throw new AuthException(
                    HttpStatus.TOO_MANY_REQUESTS,
                    "Vui lòng chờ trước khi yêu cầu mã mới"
            );
        }

        createOtp(user, OtpToken.Purpose.RESET_PASSWORD);
        return new MessageResponse("Mã khôi phục mật khẩu đã được gửi.");
    }

    @Transactional
    public MessageResponse resetPassword(ResetPasswordRequest request) {
        OtpToken token = otpTokenRepository
                .findTopByOtpCodeAndPurposeAndUsedFalseOrderByCreatedAtDesc(
                        request.resetToken(), OtpToken.Purpose.RESET_PASSWORD
                )
                .orElseThrow(() -> new AuthException(
                        HttpStatus.BAD_REQUEST, "Reset token không hợp lệ"
                ));

        if (token.isExpired()) {
            throw new AuthException(HttpStatus.GONE, "Reset token đã hết hạn");
        }

        User user = token.getUser();
        user.setPassword(passwordEncoder.encode(request.newPassword()));
        token.markUsed();
        userRepository.save(user);
        otpTokenRepository.save(token);

        return new MessageResponse("Đặt lại mật khẩu thành công.");
    }

    private OtpToken createOtp(User user, OtpToken.Purpose purpose) {
        String otp = String.format("%06d", secureRandom.nextInt(1_000_000));
        OtpToken token = new OtpToken(
                user,
                otp,
                purpose,
                LocalDateTime.now().plusMinutes(OTP_EXPIRY_MINUTES)
        );

        OtpToken savedToken = otpTokenRepository.save(token);
        log.info("[OTP MOCK] purpose={}, identifier={}, otp={}",
                purpose, user.getIdentifier(), otp);
        return savedToken;
    }

    private String normalizeIdentifier(String identifier) {
        return identifier.trim().toLowerCase();
    }
}
