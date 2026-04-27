import 'dart:convert';

import 'package:app/data/api/api_error.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('loads session analysis from backend', () async {
    late http.Request capturedRequest;
    final client = AnalysisApiClient(
      httpClient: MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode(<String, Object>{
            'session_id': 'session-1',
            'classification': 'suspicious',
            'signals': <String>['prompt-injection'],
            'attack_patterns': <String>['secret-extraction'],
            'intent_summary': 'Tried to get the secret.',
            'request_count': 1,
            'suspicion_count': 1,
            'model_fail_count': 0,
            'requests': <Object>[],
          }),
          200,
        );
      }),
      apiBaseUri: Uri.parse('http://localhost:8080'),
      userId: 'user-123',
    );

    final response = await client.getSessionAnalysis('session-1');

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.url.path, '/analysis/session/session-1');
    expect(capturedRequest.headers['X-User-Id'], 'user-123');
    expect(response.analysis.classification, 'suspicious');
    expect(response.analysis.signals, <String>['prompt-injection']);
  });

  test('loads request analysis from backend', () async {
    late http.Request capturedRequest;
    final client = AnalysisApiClient(
      httpClient: MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode(<String, Object>{
            'request_id': 'request-1',
            'session_id': 'session-1',
            'completed_at': '2026-04-21T10:00:00Z',
            'classification': 'clean',
            'signals': <String>[],
            'attack_patterns': <String>[],
            'intent_summary': '',
            'event_count': 3,
            'suspicion_count': 0,
            'model_fail_count': 0,
          }),
          200,
        );
      }),
      apiBaseUri: Uri.parse('http://localhost:8080'),
      userId: 'user-123',
    );

    final response = await client.getRequestAnalysis('request-1');

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.url.path, '/analysis/request/request-1');
    expect(capturedRequest.headers['X-User-Id'], 'user-123');
    expect(response.analysis.requestId, 'request-1');
    expect(response.analysis.eventCount, 3);
  });

  test('throws analysis exception with backend error code', () async {
    final client = AnalysisApiClient(
      httpClient: MockClient((_) async {
        return http.Response(
          jsonEncode(<String, Object>{
            'error': <String, String>{'code': 'request_analysis_not_found'},
          }),
          404,
        );
      }),
      apiBaseUri: Uri.parse('http://localhost:8080'),
      userId: 'user-123',
    );

    expect(
      () => client.getRequestAnalysis('missing-request'),
      throwsA(
        isA<AnalysisApiException>()
            .having((error) => error.statusCode, 'statusCode', 404)
            .having(
              (error) => error.code,
              'code',
              ApiErrorCode.requestAnalysisNotFound,
            ),
      ),
    );
  });
}
