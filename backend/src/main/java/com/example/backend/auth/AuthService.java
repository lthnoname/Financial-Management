package com.example.backend.auth;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.backend.common.AuthException;
import com.example.backend.config.JwtService;
import com.example.backend.user.User;
import com.example.backend.user.UserRepository;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

    private final UserRepository userRepository;
    private final OtpTokenRepository otpTokenRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final long refreshTokenExpirationDays;
    private final SecureRandom secureRandom = new SecureRandom();

    private static final int MAX_OTP_ATTEMPTS = 5;
    private static final int OTP_EXPIRY_MINUTES = 10;
    private static final int OTP_RESEND_COOLDOWN_SECONDS = 60;

    public AuthService(
            UserRepository userRepository,
            OtpTokenRepository otpTokenRepository,
            RefreshTokenRepository refreshTokenRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            @org.springframework.beans.factory.annotation.Value("${app.jwt.refresh-token-expiration-days:30}")
            long refreshTokenExpirationDays
    ) {
        this.userRepository = userRepository;
        this.otpTokenRepository = otpTokenRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.refreshTokenExpirationDays = refreshTokenExpirationDays;
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

    @Transactional(noRollbackFor = AuthException.class)
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

    @Transactional
    public LoginResponse login(LoginRequest request) {
        String identifier = normalizeIdentifier(request.identifier());
        User user = userRepository.findByIdentifier(identifier).orElseThrow(() ->
                new AuthException(HttpStatus.UNAUTHORIZED, "Identifier hoặc mật khẩu không đúng")
        );

        if (Boolean.TRUE.equals(user.getVerificationRequired())) {
            throw new AuthException(HttpStatus.UNAUTHORIZED, "Tài khoản chưa được xác thực OTP");
        }

        if (!passwordEncoder.matches(request.password(), user.getPassword())) {
            throw new AuthException(HttpStatus.UNAUTHORIZED, "Identifier hoặc mật khẩu không đúng");
        }

        String accessToken = jwtService.generateAccessToken(user);
        String refreshTokenValue = UUID.randomUUID() + UUID.randomUUID().toString();
        refreshTokenRepository.save(new RefreshToken(
                user,
                refreshTokenValue,
                LocalDateTime.now().plusDays(refreshTokenExpirationDays)
        ));

        return new LoginResponse(
                accessToken,
                refreshTokenValue,
                new UserAuthResponse(user.getId(), user.getIdentifier(), user.getFullName())
        );
    }

    @Transactional(noRollbackFor = AuthException.class)
    public AccessTokenResponse refresh(RefreshRequest request) {
        RefreshToken refreshToken = refreshTokenRepository
                .findByTokenAndRevokedFalse(request.refreshToken())
                .orElseThrow(() -> new AuthException(
                        HttpStatus.UNAUTHORIZED, "Refresh token không hợp lệ hoặc đã bị thu hồi"
                ));

        if (refreshToken.isExpired()) {
            refreshToken.revoke();
            refreshTokenRepository.save(refreshToken);
            throw new AuthException(HttpStatus.UNAUTHORIZED, "Refresh token đã hết hạn");
        }

        return new AccessTokenResponse(jwtService.generateAccessToken(refreshToken.getUser()));
    }

    @Transactional
    public void logout(RefreshRequest request, String authenticatedIdentifier) {
        RefreshToken refreshToken = refreshTokenRepository
                .findByTokenAndRevokedFalse(request.refreshToken())
                .orElseThrow(() -> new AuthException(
                        HttpStatus.UNAUTHORIZED, "Refresh token không hợp lệ hoặc đã bị thu hồi"
                ));

        if (!refreshToken.getUser().getIdentifier().equals(authenticatedIdentifier)) {
            throw new AuthException(HttpStatus.UNAUTHORIZED, "Refresh token không thuộc tài khoản đăng nhập");
        }

        refreshToken.revoke();
        refreshTokenRepository.save(refreshToken);
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
