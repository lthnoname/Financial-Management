CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    -- FR -01 
    identifier VARCHAR(100) UNIQUE NOT NULL, 
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    -- FR - 02 và connection to FR - 01 
    verification_required BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

---- FR-03
CREATE TABLE refresh_tokens (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    expiry_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Khóa ngoại liên kết với bảng users, nếu user bị xóa thì token cũng bị xóa theo (CASCADE)
    CONSTRAINT fk_refresh_token_user 
        FOREIGN KEY(user_id) 
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- Phải tạo bảng categories trước vì transactions và budgets cần tham chiếu đến nó
CREATE TABLE categories (
   id SERIAL PRIMARY KEY, 
   user_id INT NOT NULL, 
   name VARCHAR(100) NOT NULL, 
   type VARCHAR(20) NOT NULL, 
   CONSTRAINT chk_category_type CHECK (type IN ('INCOME', 'EXPENSE')), 
   CONSTRAINT fk_category_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE transactions (
   id SERIAL PRIMARY KEY, 
   user_id INT NOT NULL, 
   category_id INT, 
   amount DECIMAL (15,2) NOT NULL, 
   transaction_date DATE NOT NULL,
   note TEXT, 
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
   CONSTRAINT check_transaction_amount CHECK (amount > 0), 
   CONSTRAINT fk_transaction_user FOREIGN KEY (user_id) REFERENCES users(id),
   -- Bổ sung khóa ngoại tham chiếu đến categories
   CONSTRAINT fk_transaction_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE budgets (
    id SERIAL PRIMARY KEY, -- PK
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CONSTRAINT chk_budget_amount CHECK (amount > 0), -- CHECK
    CONSTRAINT chk_budget_dates CHECK (end_date >= start_date), -- CHECK
    CONSTRAINT fk_budget_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE, -- FK
    CONSTRAINT fk_budget_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE -- FK
);
