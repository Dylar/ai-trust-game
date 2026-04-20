import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/app/trust_game_app.dart';

void main() {
  testWidgets('shows bootstrap screen', (tester) async {
    await tester.pumpWidget(const TrustGameApp());

    expect(find.text('AI Trust Game'), findsOneWidget);
    expect(find.text('Session Start'), findsOneWidget);
    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Prepare session'), findsOneWidget);
  });

  testWidgets('prepares a local session draft', (tester) async {
    await tester.pumpWidget(const TrustGameApp());

    await tester.tap(find.text('Admin'));
    await tester.scrollUntilVisible(find.text('Hard'), 200);
    await tester.tap(find.text('Hard'));
    await tester.scrollUntilVisible(find.text('Prepare session'), 200);
    await tester.tap(find.text('Prepare session'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.textContaining('Prepared Admin session in Hard mode'),
      findsOneWidget,
    );
  });
}
