import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('shows bootstrap screen', (tester) async {
    await tester.pumpWidget(const TrustGameApp());

    expect(find.text('AI Trust Game'), findsOneWidget);
    expect(find.text('Flutter Web App is running.'), findsOneWidget);
    expect(find.textContaining('Project starts here'), findsOneWidget);
  });
}
