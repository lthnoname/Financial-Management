# Tài liệu Đặc tả REST API (API Specification) — Financial Management

## 1. Thông tin chung (General Information)

- **Base URL (Local)**: `http://localhost:8080/api/v1`
  - *(Android Emulator)*: `http://10.0.2.2:8080/api/v1`
- **Content-Type**: `application/json; charset=UTF-8`
- **Swagger UI**: `http://localhost:8080/swagger-ui.html`
- **OpenAPI Spec**: `http://localhost:8080/v3/api-docs`
- **Cơ chế Xác thực (Auth)**:
  - `Không`: Public API, không cần truyền header `Authorization`.
  - `Bearer`: Truyền Access Token vào header: `Authorization: Bearer <accessToken>`
  - `Refresh token`: Truyền `refreshToken` trong Request Body để cấp lại `accessToken`.
- **Quy tắc dữ liệu chung**:
  - Mỗi người dùng chỉ đọc/sửa được dữ liệu của chính mình (`NFR-02`).
  - Giao dịch (`transactions`) áp dụng **xóa mềm (soft delete)** (`FR-10`).
  - Đơn vị tiền tệ & múi giờ mặc định: `VND` / `Asia/Saigon` (`FR-26`).

---

## 2. Quy ước Định dạng Lỗi Thống nhất (`NFR-06`)

Tất cả lỗi trả về từ Backend (qua `GlobalExceptionHandler`) tuân theo cấu trúc JSON thống nhất:

```json
{
  "timestamp": "2026-11-17T09:30:00.000000",
  "status": 400,
  "error": "Bad Request",
  "message": "Thông báo lỗi chi tiết hiển thị cho người dùng"
}
```

| Mã HTTP | Ý nghĩa trong hệ thống |
| :--- | :--- |
| `400 Bad Request` | Dữ liệu đầu vào không hợp lệ (trống, sai định dạng, số tiền `<= 0`...) |
| `401 Unauthorized` | Chưa đăng nhập, sai thông tin đăng nhập, hoặc token hết hạn/không hợp lệ |
| `403 Forbidden` | Truy cập hoặc chỉnh sửa dữ liệu của người dùng khác / danh mục hệ thống |
| `404 Not Found` | Không tìm thấy bản ghi (người dùng, giao dịch, ngân sách...) |
| `409 Conflict` | Trùng lặp dữ liệu (trùng `identifier`, trùng tên danh mục, trùng kỳ ngân sách, xóa danh mục đang có giao dịch) |
| `410 Gone` | Mã OTP hoặc `resetToken` đã hết hạn |
| `422 Unprocessable Entity` | Dữ liệu hợp lệ về cú pháp nhưng sai quy tắc nghiệp vụ (ví dụ: mật khẩu cũ không khớp, số dư đầu kỳ `< 0`) |
| `429 Too Many Requests` | Gửi yêu cầu OTP / quên mật khẩu vượt quá giới hạn cho phép |

---

## 3. Bảng Tổng hợp Danh sách REST API (Theo Sheet `API chính`)

| # | Nhóm | Method | Endpoint | Auth | Request chính | Response chính | Mã lỗi | Yêu cầu | Phụ trách |
| :-: | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| 0 | **Health** | `GET` | `/api/v1/health` | Không | - | `status` | - | Base | TV5 |
| 1 | **Auth** | `POST` | `/api/v1/auth/register` | Không | `identifier` (email/phone), `password`, `fullName` | `userId`, `verificationRequired`, `message` | `400`, `409` | FR-01 | TV4 |
| 2 | **Auth** | `POST` | `/api/v1/auth/verify-otp` | Không | `identifier`, `otp` | `verified`, `message` | `400`, `410` | FR-02 | TV4 |
| 3 | **Auth** | `POST` | `/api/v1/auth/login` | Không | `identifier`, `password` | `accessToken`, `refreshToken`, `user` | `401` | FR-03 | TV4 |
| 4 | **Auth** | `POST` | `/api/v1/auth/refresh` | Refresh token | `refreshToken` | `accessToken` | `401` | FR-03 | TV4 |
| 5 | **Auth** | `POST` | `/api/v1/auth/logout` | Bearer | `refreshToken` | `204 No Content` | `401` | FR-03 | TV4 |
| 6 | **Auth** | `POST` | `/api/v1/auth/forgot-password` | Không | `identifier` | `message` | `404`, `429` | FR-04 | TV4 |
| 7 | **Auth** | `POST` | `/api/v1/auth/reset-password` | Không | `resetToken`, `newPassword` | `message` | `400`, `410` | FR-04 | TV4 |
| 8 | **User** | `GET`/`PATCH` | `/api/v1/me` | Bearer | profile fields (`fullName`, `avatar`, `oldPassword`, `newPassword`, `currency`, `timezone`, `openingBalance`) | user profile | `401`, `422` | FR-05, FR-26, FR-27 | TV2, TV4 |
| 9 | **Category** | `GET`/`POST` | `/api/v1/categories` | Bearer | `name`, `type` (`INCOME`/`EXPENSE`) | category or list | `400`, `409` | FR-12, FR-13 | TV5 |
| 10 | **Category** | `PATCH`/`DELETE` | `/api/v1/categories/{id}` | Bearer | `name`, `isActive` | `204` or category | `403`, `409` | FR-14 | TV5 |
| 11 | **Transaction** | `GET` | `/api/v1/transactions` | Bearer | `from`, `to`, `type`, `categoryId`, `page`, `size` | paged transactions | `400`, `401` | FR-11 | TV5 |
| 12 | **Transaction** | `POST` | `/api/v1/transactions` | Bearer | `type`, `amount`, `categoryId`, `date`, `note` | transaction | `400`, `403` | FR-06, FR-07, FR-08 | TV5 |
| 13 | **Transaction** | `GET`/`PATCH` | `/api/v1/transactions/{id}` | Bearer | editable fields (`amount`, `categoryId`, `date`, `note`) | transaction | `403`, `404` | FR-09, FR-10 | TV5 |
| 14 | **Transaction** | `DELETE` | `/api/v1/transactions/{id}` | Bearer | - | `204 No Content` | `403`, `404` | FR-10 | TV5 |
| 15 | **Budget** | `GET`/`POST` | `/api/v1/budgets` | Bearer | `month`, `categoryId`, `limitAmount` | budget / progress | `400`, `409` | FR-15, FR-17 | TV5 |
| 16 | **Budget** | `PATCH`/`DELETE` | `/api/v1/budgets/{id}` | Bearer | `limitAmount` | `204` or budget | `403`, `404` | FR-16 | TV5 |
| 17 | **Report** | `GET` | `/api/v1/reports/summary` | Bearer | `from`, `to` | `income`, `expense`, `netCashFlow` | `400` | FR-19 đến FR-23 | TV6 |
| 18 | **Report** | `GET` | `/api/v1/reports/by-category` | Bearer | `from`, `to`, `type` | category totals | `400` | FR-22, FR-23 | TV6 |
| 19 | **Report** | `GET` | `/api/v1/reports/export.csv` | Bearer | `from`, `to`, `filters` | CSV stream (`UTF-8`) | `400`, `500` | FR-24 | TV6 |
| 20 | **Report** | `GET` | `/api/v1/reports/export.pdf` | Bearer | `from`, `to`, `filters` | PDF stream | `400`, `500` | FR-25 | TV6 |

---

## 4. Đặc tả Chi tiết Từng Phân hệ (Detailed API Specifications)

### 4.1. Phân hệ Xác thực — Auth (`FR-01` -> `FR-04`)

#### 1) Đăng ký tài khoản (`FR-01`)
- **Endpoint**: `POST /api/v1/auth/register`
- **Auth**: Không
- **Request Body**:
  ```json
  {
    "identifier": "user@example.com",
    "password": "password123",
    "fullName": "Nguyễn Văn A"
  }
  ```
  - `identifier`: Bắt buộc, tối đa 100 ký tự (tự động `trim().toLowerCase()`).
  - `password`: Bắt buộc, tối thiểu 6 ký tự (mã hóa BCrypt).
  - `fullName`: Bắt buộc, tối đa 100 ký tự.
- **Response (`201 Created` / `200 OK`)**:
  ```json
  {
    "userId": 1,
    "verificationRequired": true,
    "message": "Đăng ký thành công. Vui lòng xác thực mã OTP."
  }
  ```
- **Mã lỗi**: `400` (dữ liệu không hợp lệ), `409` (`"Người dùng đã tồn tại"`).

#### 2) Xác thực mã OTP (`FR-02`)
- **Endpoint**: `POST /api/v1/auth/verify-otp`
- **Auth**: Không
- **Request Body**:
  ```json
  {
    "identifier": "user@example.com",
    "otp": "123456"
  }
  ```
- **Response (`200 OK`)**:
  ```json
  {
    "verified": true,
    "message": "Xác thực tài khoản thành công."
  }
  ```
- **Mã lỗi**: `400` (sai mã OTP hoặc vượt quá số lần thử), `410` (mã OTP đã hết hạn).

#### 3) Đăng nhập (`FR-03`)
- **Endpoint**: `POST /api/v1/auth/login`
- **Auth**: Không
- **Request Body**:
  ```json
  {
    "identifier": "user@example.com",
    "password": "password123"
  }
  ```
- **Response (`200 OK`)**:
  ```json
  {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
    "user": {
      "id": 1,
      "identifier": "user@example.com",
      "fullName": "Nguyễn Văn A"
    }
  }
  ```
- **Mã lỗi**: `401` (sai tài khoản/mật khẩu hoặc tài khoản chưa xác thực OTP).

#### 4) Làm mới Access Token (`FR-03`)
- **Endpoint**: `POST /api/v1/auth/refresh`
- **Auth**: Refresh token
- **Request Body**:
  ```json
  {
    "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4..."
  }
  ```
- **Response (`200 OK`)**:
  ```json
  {
    "accessToken": "eyJhbGciOiJIUzI1NiIs..."
  }
  ```
- **Mã lỗi**: `401` (refresh token không hợp lệ hoặc đã hết hạn/thu hồi).

#### 5) Đăng xuất (`FR-03`)
- **Endpoint**: `POST /api/v1/auth/logout`
- **Auth**: Bearer
- **Request Body**:
  ```json
  {
    "refreshToken": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4..."
  }
  ```
- **Response**: `204 No Content` (vô hiệu hóa refresh token trong bảng `refresh_tokens`).
- **Mã lỗi**: `401`.

#### 6) Quên mật khẩu (`FR-04`)
- **Endpoint**: `POST /api/v1/auth/forgot-password`
- **Auth**: Không
- **Request Body**:
  ```json
  {
    "identifier": "user@example.com"
  }
  ```
- **Response (`200 OK`)**:
  ```json
  {
    "message": "Mã khôi phục mật khẩu đã được gửi."
  }
  ```
- **Mã lỗi**: `404` (không tìm thấy tài khoản), `429` (yêu cầu gửi lại quá nhanh).

#### 7) Đặt lại mật khẩu (`FR-04`)
- **Endpoint**: `POST /api/v1/auth/reset-password`
- **Auth**: Không
- **Request Body**:
  ```json
  {
    "resetToken": "123456",
    "newPassword": "newPassword123"
  }
  ```
- **Response (`200 OK`)**:
  ```json
  {
    "message": "Đặt lại mật khẩu thành công."
  }
  ```
- **Mã lỗi**: `400` (mật khẩu mới không hợp lệ / token sai), `410` (token hết hạn).

---

### 4.2. Phân hệ Người dùng & Thiết lập — User (`FR-05`, `FR-26`, `FR-27`)

- **Endpoint**: `GET /api/v1/me` & `PATCH /api/v1/me`
- **Thiết lập ví (Sprint 2 / TV5)**: `PATCH` nhận từng trường `currency`, `timezone`, `openingBalance` và giữ giá trị của các trường bị bỏ qua. Mặc định là `VND`, `Asia/Saigon` và `0.00`. Giá trị tiền tệ, múi giờ hoặc số dư không hợp lệ trả về `422`.
- **Auth**: Bearer
- **Response `GET /api/v1/me` (`200 OK`)**:
  ```json
  {
    "id": 1,
    "identifier": "user@example.com",
    "fullName": "Nguyễn Văn A",
    "currency": "VND",
    "timezone": "Asia/Saigon",
    "openingBalance": 5000000
  }
  ```
- **Request `PATCH /api/v1/me`** (Cập nhật hồ sơ, đổi mật khẩu hoặc cài đặt số dư đầu kỳ):
  ```json
  {
    "fullName": "Nguyễn Văn A",
    "currency": "VND",
    "timezone": "Asia/Saigon",
    "openingBalance": 5000000,
    "oldPassword": "password123",
    "newPassword": "newPassword456"
  }
  ```
- **Mã lỗi**: `401` (chưa xác thực), `422` (`openingBalance < 0` hoặc `oldPassword` không đúng khi đổi mật khẩu).

---

### 4.3. Phân hệ Danh mục — Category (`FR-12`, `FR-13`, `FR-14`)

- **`GET /api/v1/categories`** (Auth: Bearer): Lấy danh mục mặc định và cá nhân của tài khoản hiện tại. Mỗi mục có `id`, `name`, `type`, `isSystem` và `isActive`. Khi chọn danh mục cho giao dịch mới, chỉ hiển thị mục có `isActive = true`.
- **`POST /api/v1/categories`** (Auth: Bearer): Tạo danh mục cá nhân (`FR-13`).
  ```json
  {
    "name": "Ăn uống",
    "type": "EXPENSE"
  }
  ```
    - Mã lỗi: `400` (tên rỗng/sai loại), `409` (trùng tên trong cùng tài khoản và loại thu/chi, không phân biệt hoa thường).
- **`PATCH /api/v1/categories/{id}`** & **`DELETE /api/v1/categories/{id}`** (Auth: Bearer): Sửa tên/trạng thái `isActive` hoặc xóa danh mục cá nhân (`FR-14`).
  - Mã lỗi: `403` (cố sửa/xóa danh mục hệ thống hoặc của người khác), `409` (xóa danh mục đang được giao dịch sử dụng — gợi ý chuyển sang vô hiệu hóa `isActive = false`).

---

### 4.4. Phân hệ Giao dịch — Transaction (`FR-06` -> `FR-11` | Phụ trách: TV5)

- **`GET /api/v1/transactions`** (Auth: Bearer | `FR-11`):
  - **Query Params**: `from` (ISO date), `to` (ISO date), `type` (`INCOME`/`EXPENSE`), `categoryId`, `page` (mặc định `0`), `size` (mặc định `20`).
  - **Response (`200 OK`)**: Danh sách giao dịch phân trang (chỉ lấy các giao dịch chưa xóa mềm, sắp xếp mới nhất).
- **`POST /api/v1/transactions`** (Auth: Bearer | `FR-06`, `FR-07`, `FR-08`):
  ```json
  {
    "type": "EXPENSE",
    "amount": 150000,
    "categoryId": 3,
    "date": "2026-11-17",
    "note": "Ăn trưa cùng nhóm"
  }
  ```
  - Ràng buộc: `amount > 0` (kiểu `NUMERIC`), `categoryId` và `date` bắt buộc.
  - Mã lỗi: `400` (dữ liệu không hợp lệ), `403` (danh mục không thuộc quyền sử dụng).
- **`GET /api/v1/transactions/{id}`** & **`PATCH /api/v1/transactions/{id}`** (Auth: Bearer | `FR-09`, `FR-10`): Xem chi tiết hoặc chỉnh sửa giao dịch.
  - Mã lỗi: `403` (không phải chủ sở hữu), `404` (không tìm thấy hoặc đã xóa mềm).
- **`DELETE /api/v1/transactions/{id}`** (Auth: Bearer | `FR-10`): Xóa mềm giao dịch (`204 No Content`).

---

### 4.5. Phân hệ Ngân sách — Budget (`FR-15` -> `FR-18`)

- **`GET /api/v1/budgets`** & **`POST /api/v1/budgets`** (Auth: Bearer):
  - **Request `POST`**:
    ```json
    {
      "month": "2026-11",
      "categoryId": 3,
      "limitAmount": 3000000
    }
    ```
  - **Response (`200 OK` / `201 Created`)** (Kèm tiến độ sử dụng và trạng thái cảnh báo `80%` / `100%` theo `FR-17`, `FR-18`):
    ```json
    {
      "id": 10,
      "month": "2026-11",
      "categoryId": 3,
      "categoryName": "Ăn uống",
      "limitAmount": 3000000,
      "spentAmount": 2500000,
      "remainingAmount": 500000,
      "usagePercentage": 83.33,
      "warningStatus": "NEAR_LIMIT"
    }
    ```
  - **Mã lỗi**: `400` (`limitAmount <= 0`), `409` (đã tồn tại ngân sách cho danh mục này trong cùng tháng).
- **`PATCH /api/v1/budgets/{id}`** & **`DELETE /api/v1/budgets/{id}`** (Auth: Bearer | `FR-16`): Cập nhật `limitAmount` hoặc xóa ngân sách. Mã lỗi: `403`, `404`.

---

### 4.6. Phân hệ Báo cáo & Xuất dữ liệu — Report (`FR-19` -> `FR-25`)

- **`GET /api/v1/reports/summary?from=2026-06-01&to=2026-11-30`** (Auth: Bearer | `FR-19` -> `FR-23`):
  - Trả về tổng thu (`income`), tổng chi (`expense`), dòng tiền ròng (`netCashFlow`), số dư hiện tại (`openingBalance + income - expense`) và thống kê theo 6 tháng gần nhất.
- **`GET /api/v1/reports/by-category?from=2026-11-01&to=2026-11-30&type=EXPENSE`** (Auth: Bearer | `FR-22`, `FR-23`):
  - Trả về danh sách tổng tiền và tỷ lệ phần trăm theo từng danh mục để vẽ biểu đồ.
- **`GET /api/v1/reports/export.csv`** & **`GET /api/v1/reports/export.pdf`** (Auth: Bearer | `FR-24`, `FR-25`):
  - Trả về luồng file CSV (`text/csv; charset=UTF-8`) hoặc PDF (`application/pdf`) theo bộ lọc `from`, `to`, `type`, `categoryId`.
