package com.example.backend.auth;

import com.example.backend.common.AuthException;
import com.example.backend.user.User;
import com.example.backend.user.UserRepository;

import java.security.SecureRandom;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public RegisterResponse register(RegisterRequest request) {
        String normalizedIdentifier = request.getIdentifier().trim().toLowerCase();

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

        // In mã OTP giả lập ra console để chuẩn bị test bước FR-02
        String otp = String.format("%06d", new SecureRandom().nextInt(1_000_000));
        log.info("[OTP MOCK] Mã xác thực cho {} là: {}", normalizedIdentifier, otp);

        return new RegisterResponse(
                savedUser.getId(),
                savedUser.getVerificationRequired(),
                "Đăng ký thành công. Vui lòng xác thực mã OTP."
        );
    }
}