# Database Schema (Sprint 1) 
Người thiết kế: Chi - TV 4 
Hệ quản trị CSDL: PostgreSQL 
 ## 1. Sơ đồ thiết kế thực thể ERD
 erDiagram
    USERS ||--o{ REFRESH_TOKENS : "has"
    USERS ||--o{ CATEGORIES : "creates"
    USERS ||--o{ TRANSACTIONS : "makes"
    USERS ||--o{ BUDGETS : "sets"
    CATEGORIES ||--o{ TRANSACTIONS : "categorizes"
    CATEGORIES ||--o{ BUDGETS : "limits"

    USERS {
        int id PK
        varchar identifier "UNIQUE"
        varchar password
        varchar full_name
        boolean verification_required
        timestamp created_at
    }
    REFRESH_TOKENS {
        int id PK
        int user_id FK
        varchar token "UNIQUE"
        timestamp expiry_date
        timestamp created_at
    }
    CATEGORIES {
        int id PK
        int user_id FK
        varchar name
        varchar type "INCOME / EXPENSE"
    }
    TRANSACTIONS {
        int id PK
        int user_id FK
        int category_id FK
        decimal amount "> 0"
        date transaction_date
        text note
        timestamp created_at
    }
    BUDGETS {
        int id PK
        int user_id FK
        int category_id FK
        decimal amount "> 0"
        date start_date
        date end_date ">= start_date"
    }

## 2. Chi tiết dữ liệu từng bảng 
# 2.1 Bảng user (Thông tin người dùng)
Tên cột               |     Kiểu dữ liệu  |       Ràng buộc          |    Mô tả 
------------------------------------------------------------------------------------------------------
id                    |     SERIAL        |       PK                 |    Khóa chính tự tăng
identifier            |     VARCHAR(100)  |       NOT NULL, UNIQUE   |    Email hoặc Số điện thoại đăng nhập (FR-01)
full_name             |     VARCHAR(255)  |       NOT NULL           |    Mật khẩu đã được mã hóa (Hash)
                      |     VARCHAR(100)  |       NOT NULL           |    Họ và tên người dùng 
verification_required |     BOOLEAN       |       DEFAULT TRUE       |    Cờ yêu cầu xác thực OTP (FR-02)
created_at            |     TIMESTAMP     |       DEFAULT            |    Thời gian tạo tài khoản  
                                                  CURRENT_TIMESTAMP  

# 2.2 Bảng refresh_tokens (Quản lý phiên đăng nhập)
Tên cột               |     Kiểu dữ liệu  |       Ràng buộc                 |    Mô tả  
----------------------------------------------------------------------------------------------------------------------------
id                    |     SERIAL        |       PK                        |    Khóa chính tự tăng
user_id               |     INT           |       NOT NULL, FK              |    Liên kết tới users(id). CASCADED on delete
token                 |     VARCHAR(255)  |       NOT NULL, UNIQUE          |    Chuỗi refresh token
expiry_date           |     TIMESTAMP     |       NOT NULL                  |    Thời gian hết hạn của token
created_at            |     TIMESTAMP     |       DEFAULT CURRENT_TIMESTAMP |    Thời gian tạo token

# 2.3 Bảng Categories 
Tên cột               |     Kiểu dữ liệu  |       Ràng buộc                 |    Mô tả   
-----------------------------------------------------------------------------------------------------
id                    |     SERIAL        |       PK                        |    Khóa chính tự tăng
user_id               |     INT           |       NOT NULL, FK              |    Liên kết tới users(id)
name                  |     VARCHAR(100)  |       NOT NULL                  |    Tên danh mục (vd: Ăn uống, Lương...)
type                  |     VARCHAR(20)   |       NOT NULL                  |    Loại danh mục, CHECK: INCOME hoặc EXPENSE

# 2.4 Bảng transactions (Giao dịch) 
Tên cột               |     Kiểu dữ liệu   |      Ràng buộc                 |    Mô tả   
---------------------------------------------------------------------------------------------------------------------------------
id                    |     SERIAL         |      PK                        |    Khóa chính tự tăng
user_id               |     INT            |      NOT NULL, FK              |    Liên kết tới users(id)
category_id           |     INT            |      FK                        |    Liên kết tới categories(id). ON DELETE SET NULL.
amount                |     DECIMAL(15,2)  |      NOT NULL                  |    Số tiền giao dịch, CHECK: amount > 0
transaction_date      |     DATE           |      NOT NULL                  |    Ngày thực hiện giao dịch
note                  |     TEXT           |                                |    Ghi chú thêm cho giao dịch
created_at            |     TIMESTAMP      |      DEFAULT CURRENT_TIMESTAMP |    Thời gian ghi nhận dữ liệu

# 2.5. Bảng budgets (Ngân sách) 
Tên cột               |     Kiểu dữ liệu   |      Ràng buộc                 |    Mô tả   
---------------------------------------------------------------------------------------------------------------------------------
id                    |     SERIAL         |      PK                        |    Khóa chính tự tăng
user_id               |     INT            |      NOT NULL, FK              |    Liên kết tới users(id)
category_id           |     INT            |      FK                        |    Liên kết tới categories(id). ON DELETE SET NULL.
amount                |     DECIMAL(15,2)  |      NOT NULL                  |    Số tiền ngân sách, CHECK: amount > 0
start_date            |     DATE           |      NOT NULL                  |    Ngày bắt đầu chu kỳ ngân sách
end_date              |     DATE           |      NOT NULL                  |    Ngày kết thúc, CHECK: end_date >= start_date









password

VARCHAR(255)

NOT NULL

Mật khẩu đã được mã hóa (Hash)

full_name

VARCHAR(100)

NOT NULL

Họ và tên người dùng

verification_required

BOOLEAN

DEFAULT TRUE

Cờ yêu cầu xác thực OTP (FR-02)

created_at

TIMESTAMP

DEFAULT CURRENT_TIMESTAMP

Thời gian tạo tài khoản




