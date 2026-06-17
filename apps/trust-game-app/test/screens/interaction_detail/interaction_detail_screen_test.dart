import 'package:flutter_test/flutter_test.dart';

import 'interaction_detail_test_context.dart';

void main() {
  testWidgets('shows request analysis from the backend', (tester) async {
    final context = InteractionDetailTestContext(tester);

    await context.process.startInteractionDetail('request-1');
    await context.process.waitUntilLoaded();

    await context.process.expectAnalysisLoaded(
      requestId: 'request-1',
      classification: 'clean',
    );
  });

  testWidgets('shows empty analysis state when analysis is not available yet', (
    tester,
  ) async {
    final context = InteractionDetailTestContext(tester);

    await context.process.startWithMissingAnalysis('request-1');
    await context.process.waitUntilLoaded();

    context.screenBot.expectEmptyAnalysisVisible();
  });

  testWidgets('shows app bar refresh indicator while cached analysis updates', (
    tester,
  ) async {
    final context = InteractionDetailTestContext(tester);

    final analysisService = await context.process.startWithPendingRefresh(
      requestId: 'request-1',
    );
    await context.screenBot.pump(const Duration());

    context.screenBot.expectRefreshVisible();
    await context.process.expectAnalysisLoaded(
      requestId: 'request-1',
      classification: 'cached',
    );

    analysisService.completeRefresh();
    await context.screenBot.pump(const Duration());

    context.screenBot.expectRefreshHidden();
    await context.process.expectAnalysisLoaded(
      requestId: 'request-1',
      classification: 'fresh',
    );
  });
}
