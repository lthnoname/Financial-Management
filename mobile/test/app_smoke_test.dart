import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';

void main() {
  testWidgets('application starts at login screen', (tester) async {
    await tester.pumpWidget(const FinanceApp());

    expect(find.text('Login screen'), findsOneWidget);
  });
}