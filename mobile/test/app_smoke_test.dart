import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';
import 'package:mobile/core/routing/routing.dart';

void main() {
  testWidgets('application starts at login screen', (tester) async {
    await tester.pumpWidget(const FinanceApp(initialRoute: AppRoutes.login));

    expect(find.text('Login screen'), findsOneWidget);
  });
}
