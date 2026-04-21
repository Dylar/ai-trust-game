import 'package:app/screens/interaction_detail/interaction_detail_keys.dart';
import 'package:app/screens/interaction_detail/interaction_detail_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'interaction_detail_test_context.dart';

void main() {
  testWidgets('shows request analysis from the backend', (tester) async {
    final context = InteractionDetailTestContext(tester);

    await context.appBot.startApp(
      home: const InteractionDetailScreen(requestId: 'request-1'),
    );
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.byKey(InteractionDetailKeys.screen), findsOneWidget);
    await context.process.expectAnalysisLoaded(
      requestId: 'request-1',
      classification: 'clean',
    );
  });
}
