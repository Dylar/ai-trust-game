import 'dart:convert';

import 'package:app/core/user/selected_user_controller.dart';
import '../testing/test_user_profile.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/analysis/analysis_repository.dart';
import 'package:app/models/analysis_models.dart';
import 'package:app/services/analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final selectedUser = SelectedUserController(
    initialUser: testUserProfile('test-user'),
  );

  test('returns cached session analysis without calling the backend', () async {
    var requestCount = 0;
    const cached = SessionAnalysis(
      sessionId: 'session-1',
      classification: 'cached',
      signals: <String>[],
      attackPatterns: <String>[],
      intentSummary: '',
      requestCount: 0,
      requests: <RequestAnalysis>[],
      suspicionCount: 0,
      modelFailCount: 0,
    );
    final service = AnalysisServiceImpl(
      analysisRepository: InMemoryAnalysisRepository(
        initialSessionAnalyses: const <String, SessionAnalysis>{
          'session-1': cached,
        },
      ),
      apiClient: AnalysisApiClient(
        httpClient: MockClient((_) async {
          requestCount++;
          return http.Response('', 500);
        }),
        apiBaseUri: Uri.parse('http://localhost:8080'),
        selectedUser: selectedUser,
      ),
    );

    final analysis = await service.getSessionAnalysis('session-1');

    expect(analysis?.classification, 'cached');
    expect(requestCount, 0);
  });

  test(
    'stores session analysis after refreshing it from the backend',
    () async {
      var requestCount = 0;
      final repository = InMemoryAnalysisRepository();
      final service = AnalysisServiceImpl(
        analysisRepository: repository,
        apiClient: AnalysisApiClient(
          httpClient: MockClient((_) async {
            requestCount++;
            return http.Response(
              jsonEncode(<String, Object>{
                'session_id': 'session-1',
                'classification': 'fresh',
                'signals': <String>[],
                'attack_patterns': <String>[],
                'intent_summary': '',
                'request_count': 0,
                'suspicion_count': 0,
                'model_fail_count': 0,
                'requests': <Object>[],
              }),
              200,
            );
          }),
          apiBaseUri: Uri.parse('http://localhost:8080'),
          selectedUser: selectedUser,
        ),
      );

      final beforeRefresh = await service.getSessionAnalysis('session-1');
      await service.refreshSessionAnalysis('session-1');
      final afterRefresh = await service.getSessionAnalysis('session-1');

      expect(beforeRefresh, isNull);
      expect(afterRefresh?.classification, 'fresh');
      expect(requestCount, 1);
    },
  );

  test('refreshes cached session analysis from the backend', () async {
    const cached = SessionAnalysis(
      sessionId: 'session-1',
      classification: 'cached',
      signals: <String>[],
      attackPatterns: <String>[],
      intentSummary: '',
      requestCount: 0,
      requests: <RequestAnalysis>[],
      suspicionCount: 0,
      modelFailCount: 0,
    );
    final repository = InMemoryAnalysisRepository(
      initialSessionAnalyses: const <String, SessionAnalysis>{
        'session-1': cached,
      },
    );
    final service = AnalysisServiceImpl(
      analysisRepository: repository,
      apiClient: AnalysisApiClient(
        httpClient: MockClient((_) async {
          return http.Response(
            jsonEncode(<String, Object>{
              'session_id': 'session-1',
              'classification': 'fresh',
              'signals': <String>[],
              'attack_patterns': <String>[],
              'intent_summary': '',
              'request_count': 0,
              'suspicion_count': 0,
              'model_fail_count': 0,
              'requests': <Object>[],
            }),
            200,
          );
        }),
        apiBaseUri: Uri.parse('http://localhost:8080'),
        selectedUser: selectedUser,
      ),
    );

    final cachedAnalysis = await service.getSessionAnalysis('session-1');
    await service.refreshSessionAnalysis('session-1');
    final stored = await service.getSessionAnalysis('session-1');

    expect(cachedAnalysis?.classification, 'cached');
    expect(stored?.classification, 'fresh');
  });

  test('returns cached request analysis without calling the backend', () async {
    var requestCount = 0;
    final cached = RequestAnalysis(
      requestId: 'request-1',
      sessionId: 'session-1',
      completedAt: DateTime.utc(2026, 4, 23),
      classification: 'cached',
      signals: const <String>[],
      attackPatterns: const <String>[],
      intentSummary: '',
      eventCount: 1,
      suspicionCount: 0,
      modelFailCount: 0,
    );
    final service = AnalysisServiceImpl(
      analysisRepository: InMemoryAnalysisRepository(
        initialRequestAnalyses: <String, RequestAnalysis>{'request-1': cached},
      ),
      apiClient: AnalysisApiClient(
        httpClient: MockClient((_) async {
          requestCount++;
          return http.Response('', 500);
        }),
        apiBaseUri: Uri.parse('http://localhost:8080'),
        selectedUser: selectedUser,
      ),
    );

    final analysis = await service.getRequestAnalysis('request-1');

    expect(analysis?.classification, 'cached');
    expect(requestCount, 0);
  });
}
