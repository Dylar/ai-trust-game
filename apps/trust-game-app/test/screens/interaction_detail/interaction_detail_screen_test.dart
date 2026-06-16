import 'dart:async';
import 'dart:convert';

import 'package:app/models/analysis_models.dart';
import 'package:app/screens/interaction_detail/interaction_detail_keys.dart';
import 'package:app/services/analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../testing/test_dependencies.dart';
import 'interaction_detail_test_context.dart';

void main() {
  testWidgets('shows request analysis from the backend', (tester) async {
    final context = InteractionDetailTestContext(tester);

    await context.appBot.startApp(
      homeBuilder: (router) =>
          router.buildInteractionDetailScreen(requestId: 'request-1'),
    );
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.byKey(InteractionDetailKeys.screen), findsOneWidget);
    await context.process.expectAnalysisLoaded(
      requestId: 'request-1',
      classification: 'clean',
    );
  });

  testWidgets('shows empty analysis state when analysis is not available yet', (
    tester,
  ) async {
    final context = InteractionDetailTestContext(tester);
    final dependencies = buildTestDependencies(
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode(<String, Object>{
            'error': <String, String>{'code': 'request_analysis_not_found'},
          }),
          404,
        ),
      ),
    );

    await context.appBot.startApp(
      dependencies: dependencies,
      homeBuilder: (router) =>
          router.buildInteractionDetailScreen(requestId: 'request-1'),
    );
    await tester.pump(const Duration(milliseconds: 1));

    expect(
      find.byKey(InteractionDetailKeys.emptyAnalysisState),
      findsOneWidget,
    );
    expect(
      find.text('No analysis is available for this interaction yet.'),
      findsOneWidget,
    );
    expect(find.byKey(InteractionDetailKeys.errorState), findsNothing);
    expect(find.text('The analysis could not be loaded yet.'), findsNothing);
    expect(find.text('HTTP status: 404'), findsNothing);
  });

  testWidgets('shows app bar refresh indicator while cached analysis updates', (
    tester,
  ) async {
    final context = InteractionDetailTestContext(tester);
    final analysisService = _PendingRefreshRequestAnalysisService();
    final dependencies = buildTestDependencies(
      analysisService: analysisService,
    );

    await context.appBot.startApp(
      dependencies: dependencies,
      homeBuilder: (router) =>
          router.buildInteractionDetailScreen(requestId: 'request-1'),
    );
    await tester.pump();

    expect(find.byKey(InteractionDetailKeys.refreshIndicator), findsOneWidget);
    await context.process.expectAnalysisLoaded(
      requestId: 'request-1',
      classification: 'cached',
    );

    analysisService.completeRefresh();
    await tester.pump();

    expect(find.byKey(InteractionDetailKeys.refreshIndicator), findsNothing);
    await context.process.expectAnalysisLoaded(
      requestId: 'request-1',
      classification: 'fresh',
    );
  });
}

class _PendingRefreshRequestAnalysisService implements AnalysisService {
  var _analysis = _requestAnalysis(classification: 'cached');
  final _refresh = Completer<void>();

  void completeRefresh() {
    _analysis = _requestAnalysis(classification: 'fresh');
    _refresh.complete();
  }

  @override
  Future<RequestAnalysis?> getRequestAnalysis(String requestId) async {
    return _analysis;
  }

  @override
  Future<void> refreshRequestAnalysis(String requestId) {
    return _refresh.future;
  }

  @override
  Future<SessionAnalysis?> getSessionAnalysis(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<void> refreshSessionAnalysis(String sessionId) {
    throw UnimplementedError();
  }
}

RequestAnalysis _requestAnalysis({required String classification}) {
  return RequestAnalysis(
    requestId: 'request-1',
    sessionId: 'session-1',
    completedAt: DateTime.utc(2026, 1, 1),
    classification: classification,
    signals: const <String>[],
    attackPatterns: const <String>[],
    intentSummary: '',
    eventCount: 0,
    suspicionCount: 0,
    modelFailCount: 0,
  );
}
