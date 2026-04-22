import 'package:app/screens/interaction_detail/interaction_detail_keys.dart';
import 'package:app/screens/interaction_detail/interaction_detail_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../testing/test_dependencies.dart';
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

  testWidgets('shows HTTP status when request analysis loading fails', (
    tester,
  ) async {
    final context = InteractionDetailTestContext(tester);
    final dependencies = buildTestDependencies(
      httpClient: MockClient((_) async => http.Response('', 404)),
    );

    await context.appBot.startApp(
      home: const InteractionDetailScreen(requestId: 'request-1'),
      dependencies: dependencies,
    );
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.byKey(InteractionDetailKeys.errorState), findsOneWidget);
    expect(find.text('HTTP status: 404'), findsOneWidget);
  });
}
