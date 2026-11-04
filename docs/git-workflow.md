# Git Workflow

## 1. Mục tiêu

Tài liệu này quy định cách nhóm làm việc với Git và GitHub trong dự án Financial-Management.

Nhóm sử dụng mô hình:

~~~text
main
└── develop
    ├── Hoa
    ├── Dang
    ├── Chi
    ├── An
    ├── Dan
    └── Khoa
~~~

Mỗi thành viên sử dụng một branch cá nhân xuyên suốt dự án. Không tạo branch mới theo từng sprint.

## 2. Quy tắc branch

### main

- Chứa phiên bản ổn định để demo hoặc phát hành.
- Không push trực tiếp.
- Chỉ nhận code từ develop thông qua Pull Request.
- Có thể tạo tag sau mỗi sprint, ví dụ sprint-1, sprint-2.

### develop

- Là branch tích hợp chung của cả nhóm.
- Chứa các tính năng đã được review và merge từ branch thành viên.
- Không push trực tiếp.
- Là branch đích của các Pull Request cá nhân.

### Branch thành viên

Tên branch sử dụng:

~~~text
Hoa
Dang
Chi
An
Dan
Khoa
~~~

Quy tắc:

- Mỗi branch có một thành viên phụ trách chính.
- Chỉ dùng branch để phát triển các task được phân công cho thành viên đó.
- Không tự ý push vào branch của thành viên khác.
- Branch phải thường xuyên cập nhật từ develop.
- Sau khi merge vào develop, branch cá nhân vẫn được giữ lại để tiếp tục dùng ở sprint tiếp theo.


## 3. Clone project và lấy branch

Clone repository lần đầu:

~~~bash
git clone https://github.com/lthnoname/Financial-Management.git
cd Financial-Management
~~~

Lấy danh sách branch mới nhất:

~~~bash
git fetch origin
~~~

Chuyển sang branch cá nhân, ví dụ TV1:

~~~bash
git switch --track origin/TV1
~~~

Nếu branch cá nhân chưa tồn tại trên GitHub:

~~~bash
git switch develop
git pull origin develop
git switch -c tv1
git push -u origin tv1
~~~

## 4. Cập nhật branch trước khi làm việc

Vì branch cá nhân được sử dụng xuyên suốt nhiều sprint, cần cập nhật từ develop thường xuyên.

~~~bash
git switch tv1
git fetch origin
git merge origin/develop
~~~

Nên cập nhật ít nhất một lần trước khi bắt đầu task mới và trước khi mở Pull Request.

Không cập nhật develop khi đang có thay đổi chưa commit. Hãy commit hoặc tạm lưu thay đổi trước:

~~~bash
git add .
git commit -m "wip: save current progress"
~~~

## 5. Quy tắc commit

Mỗi commit nên có một mục đích rõ ràng và không nên gom quá nhiều task không liên quan.

Định dạng:

~~~text
type(scope): mô tả ngắn
~~~

Các loại commit thường dùng:

| Type | Sử dụng cho |
|---|---|
| feat | Thêm tính năng mới |
| fix | Sửa lỗi |
| docs | Cập nhật tài liệu |
| test | Thêm hoặc sửa test |
| refactor | Cải thiện code nhưng không đổi chức năng |
| chore | Cấu hình, Docker, CI/CD hoặc công việc kỹ thuật |

Ví dụ:

~~~bash
git commit -m "feat(auth): add login endpoint"
git commit -m "feat(mobile): add transaction form"
git commit -m "fix(database): correct transaction relation"
git commit -m "test(auth): add login api test"
git commit -m "docs: update local setup guide"
git commit -m "chore(ci): configure backend workflow"
~~~

Không nên dùng các message quá chung chung:

~~~text
update
fix code
done
change
~~~

Không commit thông tin nhạy cảm như mật khẩu, API key, token hoặc file .env có dữ liệu thật.

## 6. Quy trình add, commit và push

Kiểm tra branch hiện tại:

~~~bash
git branch --show-current
~~~

Kiểm tra các file đã thay đổi:

~~~bash
git status
~~~

Thêm file cần commit:

~~~bash
git add .
~~~

Nên kiểm tra lại trước khi commit:

~~~bash
git diff --cached
~~~

Tạo commit:

~~~bash
git commit -m "feat(scope): describe the change"
~~~

Đẩy code lên branch cá nhân:

~~~bash
git push
~~~

Lần đầu push branch mới cần dùng:

~~~bash
git push -u origin member/tv1
~~~

## 7. Pull Request

Mọi thay đổi đưa vào develop phải thông qua Pull Request.

### Tạo Pull Request

Trên GitHub, chọn:

~~~text
base: develop
compare: member/tv1
~~~

Không chọn main cho Pull Request thông thường.

### Tiêu đề Pull Request

Nên ghi rõ sprint, thành viên và nội dung:

~~~text
[S1][TV1] Initialize project skeleton
[S2][TV4] Implement authentication API
[S3][TV3] Add transaction history screen
~~~

### Nội dung Pull Request

Mỗi Pull Request nên có:

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