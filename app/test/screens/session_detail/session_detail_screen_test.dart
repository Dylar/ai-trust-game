import 'package:app/screens/session_detail/session_detail_keys.dart';
import 'package:app/screens/session_detail/session_detail_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'session_detail_test_context.dart';

void main() {
  testWidgets('shows session analysis from the backend', (tester) async {
    final context = SessionDetailTestContext(tester);

    await context.appBot.startApp(
      home: const SessionDetailScreen(sessionId: 'local-admin-hard'),
    );
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.byKey(SessionDetailKeys.screen), findsOneWidget);
    await context.process.expectAnalysisLoaded(
      sessionId: 'local-admin-hard',
      classification: 'clean',
    );
  });
}
