
- Mô tả chức năng đã thực hiện.
- Danh sách task hoặc yêu cầu liên quan.
- Cách kiểm thử.
- Ảnh chụp màn hình nếu có thay đổi giao diện.
- Ghi chú về migration, cấu hình hoặc thay đổi API.

Mẫu nội dung:

~~~markdown
## Nội dung
- Thêm API đăng nhập.
- Thêm kiểm tra email và mật khẩu.

## Cách kiểm thử
- Chạy backend.
- Gọi POST /api/auth/login bằng Swagger.
- Kiểm tra response token.

## Checklist
- [ ] Code đã được format
- [ ] Đã chạy test liên quan
- [ ] Không chứa secret hoặc password thật
- [ ] Đã cập nhật tài liệu nếu cần
~~~

### Review và merge

- Mỗi Pull Request cần ít nhất một thành viên khác review.
- Người review kiểm tra code, test và ảnh hưởng đến module khác.
- Chỉ merge khi CI chạy thành công và không còn conflict.
- Ưu tiên Squash and merge nếu Pull Request có nhiều commit nhỏ.
- Sau khi merge, kiểm tra lại develop để bảo đảm project vẫn chạy được.

## 8. Xử lý conflict

Cập nhật branch cá nhân trước:

~~~bash
git switch member/tv1
git fetch origin
git merge origin/develop
~~~

Nếu có conflict, mở các file được Git thông báo và xử lý các đoạn:

~~~text
<<<<<<< HEAD
Code trên branch cá nhân
=======
Code mới từ develop
>>>>>>> origin/develop
~~~

Sau khi chọn và chỉnh sửa code đúng:

~~~bash
git add .
git commit -m "chore: resolve merge conflict"
git push
~~~

Sau đó Pull Request sẽ được cập nhật tự động.

## 9. Đưa phiên bản hoàn chỉnh vào main

Sau khi hoàn thành một sprint và kiểm thử toàn bộ trên develop, tạo Pull Request:

~~~text
develop -> main
~~~

Sau khi merge thành công, tạo tag phiên bản:

~~~bash
git switch main
git pull origin main
git tag sprint-1
git push origin sprint-1
~~~

Các sprint sau thực hiện tương tự với sprint-2, sprint-3,...

Không tạo branch mới theo từng sprint. Các branch thành viên tiếp tục được cập nhật từ develop và sử dụng xuyên suốt dự án.

## 10. Luồng làm việc chuẩn

~~~text
1. Cập nhật branch cá nhân từ develop
2. Làm task trên branch cá nhân
3. Add và commit code
4. Push lên GitHub
5. Tạo Pull Request vào develop
6. Thành viên khác review
7. Sửa theo review và cập nhật Pull Request
8. Merge vào develop
9. Kiểm thử tích hợp
10. Cuối sprint: merge develop vào main và tạo tag
~~~