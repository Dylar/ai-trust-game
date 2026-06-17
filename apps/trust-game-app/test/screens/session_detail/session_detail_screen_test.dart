import 'package:flutter_test/flutter_test.dart';

import 'session_detail_test_context.dart';

void main() {
  testWidgets('shows session analysis from the backend', (tester) async {
    final context = SessionDetailTestContext(tester);

    await context.process.startSessionDetail('local-admin-hard');
    await context.process.waitUntilLoaded();

    await context.process.expectAnalysisLoaded(
      sessionId: 'local-admin-hard',
      classification: 'clean',
    );
    await context.process.expectRequestVisible('request-1');
  });

  testWidgets('shows empty analysis state when analysis is not available yet', (
    tester,
  ) async {
    final context = SessionDetailTestContext(tester);

    await context.process.startWithMissingAnalysis('local-admin-hard');
    await context.process.waitUntilLoaded();

    context.screenBot.expectEmptyAnalysisVisible();
  });

  testWidgets('shows app bar refresh indicator while cached analysis updates', (
    tester,
  ) async {
    final context = SessionDetailTestContext(tester);

    final analysisService = await context.process.startWithPendingRefresh(
      sessionId: 'local-admin-hard',
    );
    await context.screenBot.pump(const Duration());

    context.screenBot.expectRefreshVisible();
    await context.process.expectAnalysisLoaded(
      sessionId: 'local-admin-hard',
      classification: 'cached',
    );

    analysisService.completeRefresh();
    await context.screenBot.pump(const Duration());

    context.screenBot.expectRefreshHidden();
    await context.process.expectAnalysisLoaded(
      sessionId: 'local-admin-hard',
      classification: 'fresh',
    );
  });
}
