## 5. Chi tiết công việc theo thành viên

### 5.1. TV1 - Hòa

#### S1-01: Phân rã backlog Sprint 1

Công việc:

- Phân rã mục tiêu Sprint thành các task nhỏ.
- Gán người phụ trách.
- Xác định dependency giữa các task.
- Đưa task vào GitHub Project.

Điều kiện hoàn thành:

- [ ] Có đầy đủ task cho TV1 đến TV6.
- [ ] Mỗi task có người phụ trách.
- [ ] Có priority, dependency và trạng thái.
- [ ] Có tiêu chí nghiệm thu.

#### S1-02: Vẽ wireframe luồng xác thực

Màn hình:

- Login.
- Register.
- Verify OTP.
- Forgot Password.
- Reset Password.

Điều kiện hoàn thành:

- [ ] Có wireframe cho tất cả màn hình.
- [ ] Có loading state.
- [ ] Có validation error.
- [ ] Có API error.
- [ ] Có mapping với US-01, US-02 và US-03.

#### S1-03: Vẽ wireframe Dashboard và giao dịch

Màn hình:

- Dashboard.
- Add Transaction.
- Transaction History.
- Transaction Detail.

Điều kiện hoàn thành:

- [ ] Có wireframe cho tất cả màn hình.
- [ ] Có empty state.
- [ ] Có loading và error state.
- [ ] Có mapping với US-04, US-05 và US-08.

#### S1-04: Khởi tạo Mobile skeleton

Công việc:

- Tạo cấu trúc thư mục Flutter.
- Tạo app entrypoint.
- Tạo màn hình placeholder.
- Chuẩn bị route name cho các màn hình chính.

Điều kiện hoàn thành:

- [ ] Flutter app khởi động được.
- [ ] Có thư mục `core`, `features`, `shared`.
- [ ] Có màn hình Login và Dashboard placeholder.
- [ ] `flutter analyze` không lỗi.
- [ ] `flutter test` chạy thành công.

#### S1-05: Khởi tạo Backend skeleton

Công việc:

- Chuẩn hóa module boundary.
- Tạo tài liệu kiến trúc.
- Thống nhất API prefix `/api/v1`.
- Thống nhất các module nghiệp vụ.

Module dự kiến:

- `auth`
- `user`
- `category`
- `transaction`
- `budget`
- `report`
- `common`
- `config`

Điều kiện hoàn thành:

- [ ] Có tài liệu kiến trúc.
- [ ] Có module boundary rõ ràng.
- [ ] Không trùng phạm vi với TV5.
- [ ] Backend build/test được.

#### S1-06: Thiết lập CI/CD baseline

Công việc:

- Tạo `.github/workflows/ci.yml`.
- Kiểm tra Flutter.
- Kiểm tra Backend.
- Chạy CI khi push và tạo Pull Request.

Điều kiện hoàn thành:

- [ ] Có job Mobile.
- [ ] Có job Backend.
- [ ] `flutter analyze` chạy trong CI.
- [ ] `flutter test` chạy trong CI.
- [ ] Maven test chạy trong CI.

---

### 5.2. TV2 + TV3

#### S1-07: Khởi tạo Flutter base code

Công việc:

- Kiểm tra cấu trúc Flutter do TV1 tạo.
- Chuẩn hóa cách tổ chức widget.
- Chuẩn bị nền tảng cho các màn hình về sau.

Điều kiện hoàn thành:

- [ ] Project Flutter build được.
- [ ] Cấu trúc code thống nhất.
- [ ] Không sửa chồng ngoài phạm vi đã thống nhất.
- [ ] Có tài liệu ngắn về cách thêm màn hình mới.

#### S1-08: Cấu hình routing, theme và reusable components

Công việc:

- Cấu hình routing.
- Tạo theme màu sắc và typography.
- Tạo các component dùng chung:
  - Button.
  - Input.
  - Dialog.
  - Loading indicator.
  - Error message.
  - Empty state.

Điều kiện hoàn thành:

- [ ] Có thể chuyển giữa các route mẫu.
- [ ] Theme dùng thống nhất.
- [ ] Component có thể tái sử dụng.
- [ ] Có ví dụ sử dụng component.
- [ ] Flutter test không lỗi.

---

### 5.3. TV4

#### S1-09: Khởi tạo PostgreSQL

Công việc:

- Tạo database local.
- Xác định database name, user và port.
- Kiểm tra kết nối từ Backend.

Điều kiện hoàn thành:

- [ ] PostgreSQL chạy được.
- [ ] Database được tạo đúng tên.
- [ ] Có hướng dẫn kết nối.
- [ ] Không commit password thật.

#### S1-10: Thiết kế schema và foreign key

Công việc:

- Xác định các bảng chính.
- Xác định khóa chính.
- Xác định khóa ngoại.
- Chuẩn bị migration đầu tiên.

Các bảng dự kiến:

- User.
- Category.
- Transaction.
- Budget.
- Refresh Token.

Điều kiện hoàn thành:

- [ ] Schema được thống nhất với TV5.
- [ ] Có foreign key cần thiết.
- [ ] Không tạo dữ liệu mồ côi.
- [ ] Migration chạy được trên database rỗng.
- [ ] Có tài liệu schema.

---

### 5.4. TV5

#### S1-11: Khởi tạo Spring Boot base code

Công việc:

- Kiểm tra Java 17.
- Kiểm tra Maven Wrapper.
- Cấu hình package chính.
- Chuẩn bị cấu hình môi trường.
- Chuẩn bị kết nối PostgreSQL.

Điều kiện hoàn thành:

- [ ] Backend build được.
- [ ] Backend test chạy được.
- [ ] Application khởi động được khi có database.
- [ ] Cấu hình không chứa secret.
- [ ] Package thống nhất với tài liệu kiến trúc.

#### S1-12: Cấu hình Swagger/OpenAPI

Công việc:

- Thêm thư viện Swagger/OpenAPI.
- Cấu hình thông tin API.
- Tạo endpoint mẫu hoặc health endpoint.
- Kiểm tra Swagger UI.

Điều kiện hoàn thành:

- [ ] Swagger UI truy cập được.
- [ ] Có thông tin tên project và version.
- [ ] API mẫu hiển thị trong Swagger.
- [ ] Request/response có mô tả cơ bản.
- [ ] Không làm hỏng Maven test.

---

### 5.5. TV6

#### S1-13: Cấu hình Docker Compose

Công việc:

- Tạo `docker-compose.yml`.
- Cấu hình PostgreSQL.
- Chuẩn bị service Backend.
- Khai báo network và volume.
- Viết hướng dẫn chạy local.

Điều kiện hoàn thành:

- [ ] `docker compose up` chạy được.
- [ ] PostgreSQL hoạt động trong container.
- [ ] Dữ liệu PostgreSQL có volume.
- [ ] Backend có thể kết nối database.
- [ ] Có hướng dẫn `up`, `down` và xem log.
- [ ] Không commit password production.

---

### 5.6. Tích hợp toàn nhóm

#### S1-14: Chạy thử toàn bộ project

Công việc:

- Merge các Pull Request vào `develop`.
- Chạy Mobile.
- Chạy Backend.
- Chạy PostgreSQL.
- Chạy Docker Compose.
- Kiểm tra Swagger.
- Kiểm tra CI.

Điều kiện hoàn thành:

- [ ] Mobile build được.
- [ ] Backend build/test được.
- [ ] PostgreSQL chạy được.
- [ ] Docker Compose chạy được.
- [ ] Swagger truy cập được.
- [ ] Không có conflict nghiêm trọng.

#### S1-15: Review và hoàn tất Sprint

Công việc:

- Review code của các thành viên.
- Sửa lỗi CI.
- Cập nhật README.
- Cập nhật trạng thái backlog.
- Chuẩn bị demo Sprint 1.

Điều kiện hoàn thành:

- [ ] Tất cả task quan trọng đã `Done`.
- [ ] Các PR đã được review.
- [ ] CI xanh.
- [ ] README có hướng dẫn chạy project.
- [ ] Có nội dung demo Sprint 1.