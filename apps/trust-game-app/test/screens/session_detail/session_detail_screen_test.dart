import 'dart:convert';
import 'dart:async';

import 'package:app/models/analysis_models.dart';
import 'package:app/screens/session_detail/session_detail_keys.dart';
import 'package:app/services/analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../testing/test_dependencies.dart';
import 'session_detail_test_context.dart';

void main() {
  testWidgets('shows session analysis from the backend', (tester) async {
    final context = SessionDetailTestContext(tester);

    await context.appBot.startApp(
      homeBuilder: (router) =>
          router.buildSessionDetailScreen(sessionId: 'local-admin-hard'),
    );
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.byKey(SessionDetailKeys.screen), findsOneWidget);
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
    final dependencies = buildTestDependencies(
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode(<String, Object>{
            'error': <String, String>{'code': 'session_analysis_not_found'},
          }),
          404,
        ),
      ),
    );

    await context.appBot.startApp(
      dependencies: dependencies,
      homeBuilder: (router) =>
          router.buildSessionDetailScreen(sessionId: 'local-admin-hard'),
    );
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.byKey(SessionDetailKeys.emptyAnalysisState), findsOneWidget);
    expect(
      find.text('No analysis is available for this session yet.'),
      findsOneWidget,
    );
    expect(find.byKey(SessionDetailKeys.errorState), findsNothing);
    expect(find.text('The analysis could not be loaded yet.'), findsNothing);
    expect(find.text('HTTP status: 404'), findsNothing);
  });

  testWidgets('shows app bar refresh indicator while cached analysis updates', (
    tester,
  ) async {
    final context = SessionDetailTestContext(tester);
    final analysisService = _PendingRefreshSessionAnalysisService();
    final dependencies = buildTestDependencies(
      analysisService: analysisService,
    );

    await context.appBot.startApp(
      dependencies: dependencies,
      homeBuilder: (router) =>
          router.buildSessionDetailScreen(sessionId: 'local-admin-hard'),
    );
    await tester.pump();

    expect(find.byKey(SessionDetailKeys.refreshIndicator), findsOneWidget);
    await context.process.expectAnalysisLoaded(
      sessionId: 'local-admin-hard',
      classification: 'cached',
    );

    analysisService.completeRefresh();
    await tester.pump();

    expect(find.byKey(SessionDetailKeys.refreshIndicator), findsNothing);
    await context.process.expectAnalysisLoaded(
      sessionId: 'local-admin-hard',
      classification: 'fresh',
    );
  });
}

class _PendingRefreshSessionAnalysisService implements AnalysisService {
  var _analysis = _sessionAnalysis(classification: 'cached');
  final _refresh = Completer<void>();

  void completeRefresh() {
    _analysis = _sessionAnalysis(classification: 'fresh');
    _refresh.complete();
  }

  @override
  Future<RequestAnalysis?> getRequestAnalysis(String requestId) {
    throw UnimplementedError();
  }

  @override
  Future<void> refreshRequestAnalysis(String requestId) {
    throw UnimplementedError();
  }

  @override
  Future<SessionAnalysis?> getSessionAnalysis(String sessionId) async {
    return _analysis;
  }

  @override
  Future<void> refreshSessionAnalysis(String sessionId) {
    return _refresh.future;
  }
}

SessionAnalysis _sessionAnalysis({required String classification}) {
  return SessionAnalysis(
    sessionId: 'local-admin-hard',
    classification: classification,
    signals: const <String>[],
    attackPatterns: const <String>[],
    intentSummary: '',
    requestCount: 0,
    requests: const <RequestAnalysis>[],
    suspicionCount: 0,
    modelFailCount: 0,
  );
}
