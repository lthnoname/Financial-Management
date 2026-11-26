ALTER TABLE refresh_tokens
    ADD COLUMN revoked BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX idx_refresh_tokens_active
    ON refresh_tokens (token, revoked, expiry_date);
