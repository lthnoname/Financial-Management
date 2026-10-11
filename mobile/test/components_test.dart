import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/routing/routing.dart';
import 'package:mobile/core/theme/theme.dart';
import 'package:mobile/shared/widgets/widgets.dart';

void main() {
  group('UI Components Unit & Widget Tests', () {
    testWidgets('AppButton renders label and triggers callback on tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppButton(
              label: 'Test Button',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      await tester.tap(find.text('Test Button'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('AppButton does not trigger callback when isLoading is true', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppButton(
              label: 'Loading Button',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('AppTextField toggles password visibility on icon tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AppTextField(
              label: 'Mật khẩu',
              isPassword: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('AppEmptyState displays title, subtitle and action button', (tester) async {
      bool actionClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppEmptyState(
              title: 'Không có giao dịch',
              subtitle: 'Hãy thêm giao dịch đầu tiên',
              actionLabel: 'Thêm mới',
              onAction: () => actionClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Không có giao dịch'), findsOneWidget);
      expect(find.text('Hãy thêm giao dịch đầu tiên'), findsOneWidget);
      expect(find.text('Thêm mới'), findsOneWidget);

      await tester.tap(find.text('Thêm mới'));
      await tester.pump();
      expect(actionClicked, isTrue);
    });

    testWidgets('AppErrorView displays title, error message and retry button', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppErrorView(
              title: 'Lỗi tải trang',
              message: 'Mất kết nối mạng',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Lỗi tải trang'), findsOneWidget);
      expect(find.text('Mất kết nối mạng'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);

      await tester.tap(find.text('Thử lại'));
      await tester.pump();
      expect(retried, isTrue);
    });

    testWidgets('AppLoadingIndicator displays custom message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AppLoadingIndicator(
              message: 'Đang tải dữ liệu...',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Đang tải dữ liệu...'), findsOneWidget);
    });

    test('AppRouter contains initial and login route keys', () {
      final routes = AppRouter.routes;
      expect(routes.containsKey(AppRoutes.root), isTrue);
      expect(routes.containsKey(AppRoutes.login), isTrue);
    });
  });
}
