CREATE TABLE otp_tokens (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    otp_code VARCHAR(10) NOT NULL,
    purpose VARCHAR(20) NOT NULL,
    attempt_count INT NOT NULL DEFAULT 0,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_otp_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_otp_purpose
        CHECK (purpose IN ('VERIFY_ACCOUNT', 'RESET_PASSWORD')),

    CONSTRAINT chk_otp_attempt_count
        CHECK (attempt_count >= 0)
);

CREATE INDEX idx_otp_lookup
    ON otp_tokens (user_id, purpose, used, created_at DESC);

CREATE INDEX idx_otp_code_lookup
    ON otp_tokens (otp_code, purpose, used);
