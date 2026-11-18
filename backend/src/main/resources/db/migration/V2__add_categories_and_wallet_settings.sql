ALTER TABLE categories
    ADD COLUMN is_system BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

CREATE UNIQUE INDEX uq_category_user_type_name
    ON categories (user_id, type, lower(btrim(name)));

-- Preserve references even when a transaction and a deletion are requested concurrently.
ALTER TABLE transactions DROP CONSTRAINT fk_transaction_category;
ALTER TABLE transactions ADD CONSTRAINT fk_transaction_category
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT;
ALTER TABLE budgets DROP CONSTRAINT fk_budget_category;
ALTER TABLE budgets ADD CONSTRAINT fk_budget_category
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT;
CREATE INDEX idx_transactions_category_id ON transactions (category_id);
CREATE INDEX idx_budgets_category_id ON budgets (category_id);

CREATE TABLE user_settings (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    currency VARCHAR(10) NOT NULL DEFAULT 'VND',
    timezone VARCHAR(50) NOT NULL DEFAULT 'Asia/Saigon',
    opening_balance NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_user_settings_opening_balance CHECK (opening_balance >= 0)
);

-- Give each account its own IDs so the transaction API can verify category ownership.
CREATE FUNCTION initialize_wallet_for_user(target_user_id INTEGER) RETURNS VOID
LANGUAGE SQL AS $$
    INSERT INTO user_settings (user_id) VALUES (target_user_id)
    ON CONFLICT (user_id) DO NOTHING;

    INSERT INTO categories (user_id, name, type, is_system)
    VALUES
        (target_user_id, 'Ăn uống', 'EXPENSE', TRUE),
        (target_user_id, 'Di chuyển', 'EXPENSE', TRUE),
        (target_user_id, 'Mua sắm', 'EXPENSE', TRUE),
        (target_user_id, 'Hóa đơn', 'EXPENSE', TRUE),
        (target_user_id, 'Khác', 'EXPENSE', TRUE),
        (target_user_id, 'Lương', 'INCOME', TRUE),
        (target_user_id, 'Thưởng', 'INCOME', TRUE),
        (target_user_id, 'Khác', 'INCOME', TRUE)
    ON CONFLICT (user_id, type, lower(btrim(name))) DO NOTHING;
$$;

SELECT initialize_wallet_for_user(id) FROM users;

CREATE FUNCTION initialize_wallet_on_registration() RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    PERFORM initialize_wallet_for_user(NEW.id);
    RETURN NEW;
END;
$$;

CREATE TRIGGER initialize_wallet_for_new_user
    AFTER INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION initialize_wallet_on_registration();
