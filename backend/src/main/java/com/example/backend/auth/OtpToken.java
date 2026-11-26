package com.example.backend.auth;

import com.example.backend.user.User;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "otp_tokens")
public class OtpToken {

    public enum Purpose {
        VERIFY_ACCOUNT,
        RESET_PASSWORD
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "otp_code", nullable = false, length = 10)
    private String otpCode;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Purpose purpose;

    @Column(name = "attempt_count", nullable = false)
    private int attemptCount = 0;

    @Column(nullable = false)
    private boolean used = false;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    protected OtpToken() {
    }

    public OtpToken(User user, String otpCode, Purpose purpose, LocalDateTime expiresAt) {
        this.user = user;
        this.otpCode = otpCode;
        this.purpose = purpose;
        this.expiresAt = expiresAt;
    }

    @PrePersist
    void onCreate() {
        createdAt = LocalDateTime.now();
    }

    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiresAt);
    }

    public void increaseAttempt() {
        attemptCount++;
    }

    public void markUsed() {
        used = true;
    }

    public User getUser() {
        return user;
    }

    public String getOtpCode() {
        return otpCode;
    }

    public int getAttemptCount() {
        return attemptCount;
    }
}
