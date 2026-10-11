# Financial Management - Mobile App

Ứng dụng quản lý tài chính cá nhân được phát triển bằng Flutter.

---

## 1. Cấu trúc thư mục (Architecture)

```text
mobile/
├── lib/
│   ├── app.dart                   # Khởi tạo MaterialApp, kết nối Theme & Router
│   ├── main.dart                  # Entry point của ứng dụng
│   ├── core/                      # Các tài nguyên dùng chung toàn hệ thống
│   │   ├── routing/               # Quản lý định tuyến (AppRoutes, AppRouter)
│   │   ├── theme/                 # Design System (AppColors, AppTextStyles, AppTheme)
│   │   └── network/               # Cấu hình API client (Dio/Http)
│   ├── features/                  # Các module tính năng theo nghiệp vụ (auth, dashboard...)
│   └── shared/                    # Các widget, models và tiện ích tái sử dụng
│       └── widgets/               # Bộ Reusable UI Components chuẩn (Button, Input, Dialog...)
└── test/                          # Unit và Widget tests tự động
```

---

## 2. Hướng dẫn thêm màn hình mới (Adding a New Screen)

Để thêm một màn hình mới vào ứng dụng mà vẫn đảm bảo tính nhất quán của kiến trúc, thực hiện 4 bước sau:

### Bước 1: Tạo file màn hình Widget
Tạo file trong thư mục tính năng tương ứng, ví dụ `lib/features/auth/screens/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppTextField(
              label: 'Email',
              controller: _emailController,
              hintText: 'Nhập email của bạn',
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Đăng nhập',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
```

### Bước 2: Khai báo tên Route
Mở file `lib/core/routing/app_routes.dart` và thêm hằng số định danh cho route:

```dart
class AppRoutes {
  // ...
  static const String myNewScreen = '/my-new-screen';
}
```

### Bước 3: Đăng ký Route vào Router
Mở file `lib/core/routing/app_router.dart` và map tên route với Widget màn hình:

```dart
static Map<String, WidgetBuilder> get routes => {
  // ...
  AppRoutes.myNewScreen: (_) => const MyNewScreen(),
};
```

### Bước 4: Điều hướng tới màn hình mới
Từ bất kỳ màn hình nào, sử dụng `Navigator` với tên route đã khai báo:

```dart
Navigator.of(context).pushNamed(AppRoutes.myNewScreen);
```

---

## 3. Bộ Reusable UI Components có sẵn

Toàn bộ component dùng chung được tập hợp tại `lib/shared/widgets/widgets.dart`:

* **`AppButton`**: Nút bấm hỗ trợ các biến thể (primary, secondary, outlined, danger), tự động hiển thị vòng xoay khi `isLoading: true`, hỗ trợ icon và vô hiệu hóa (`isDisabled`).
* **`AppTextField`**: Ô nhập liệu chuẩn có nhãn `label`, tự động hiển thị icon mắt bật/tắt mật khẩu khi `isPassword: true`, hiển thị thông báo lỗi `errorText`.
* **`AppDialog`**: Hộp thoại popup chuẩn với các helper methods tiện ích: `AppDialog.showConfirm(...)`, `AppDialog.showAlert(...)`, `AppDialog.showSuccess(...)`, `AppDialog.showError(...)`.
* **`AppLoadingIndicator` / `AppLoadingOverlay`**: Spinner tải trang và lớp phủ làm mờ khi submit dữ liệu.
* **`AppErrorView` / `AppErrorBanner`**: Hiển thị thông báo lỗi kèm nút "Thử lại" (`onRetry`).
* **`AppEmptyState`**: Hiển thị trạng thái danh sách trống kèm hình minh họa và nút hành động.

---

## 4. Chạy kiểm thử (Testing)

Chạy phân tích mã nguồn và toàn bộ test cases:

```bash
flutter analyze
flutter test
```
