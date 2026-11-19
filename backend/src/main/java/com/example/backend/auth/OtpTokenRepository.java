package com.example.backend.auth;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.Optional;

public interface OtpTokenRepository extends JpaRepository<OtpToken, Integer> {

    Optional<OtpToken> findTopByUserIdentifierAndPurposeAndUsedFalseOrderByCreatedAtDesc(
            String identifier,
            OtpToken.Purpose purpose
    );

    Optional<OtpToken> findTopByOtpCodeAndPurposeAndUsedFalseOrderByCreatedAtDesc(
            String otpCode,
            OtpToken.Purpose purpose
    );

    boolean existsByUserIdentifierAndPurposeAndCreatedAtAfter(
            String identifier,
            OtpToken.Purpose purpose,
            LocalDateTime createdAt
    );
}
