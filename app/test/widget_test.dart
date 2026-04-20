import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/app/trust_game_app.dart';

void main() {
  testWidgets('shows bootstrap screen', (tester) async {
    await tester.pumpWidget(const TrustGameApp());

    expect(find.text('AI Trust Game'), findsOneWidget);
    expect(find.text('Flutter app is running.'), findsOneWidget);
    expect(find.textContaining('Project starts here'), findsOneWidget);
  });
}
