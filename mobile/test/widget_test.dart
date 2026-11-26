import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';

void main() {
  testWidgets('application starts at the PocketBudget dashboard', (tester) async {
    await tester.pumpWidget(const FinanceApp());

    expect(find.text('Dòng tiền ròng'), findsOneWidget);
  });
}
