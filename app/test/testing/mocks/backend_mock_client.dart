import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Client buildBackendMockClient() {
  return MockClient((request) async {
    if (request.url.path == '/session/start') {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode(<String, String>{
          'sessionId': 'local-${body['role']}-${body['mode']}',
          'role': body['role'] as String,
          'mode': body['mode'] as String,
        }),
        200,
      );
    }

    if (request.url.path == '/interaction') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode(<String, String>{
          'message': 'Backend answer for: "${body['message']}"',
        }),
        200,
        headers: const <String, String>{'x-request-id': 'request-1'},
      );
    }

    if (request.url.path.startsWith('/analysis/session/')) {
      final sessionId = request.url.pathSegments.last;
      return http.Response(
        jsonEncode(<String, Object>{
          'session_id': sessionId,
          'classification': 'clean',
          'signals': <String>[],
          'attack_patterns': <String>[],
          'intent_summary': '',
          'request_count': 1,
          'suspicion_count': 0,
          'model_fail_count': 0,
          'requests': <Object>[
            <String, Object>{
              'request_id': 'request-1',
              'session_id': sessionId,
              'completed_at': '2026-04-21T10:00:00Z',
              'classification': 'clean',
              'signals': <String>[],
              'attack_patterns': <String>[],
              'intent_summary': '',
              'event_count': 1,
              'suspicion_count': 0,
              'model_fail_count': 0,
            },
          ],
        }),
        200,
      );
    }

    if (request.url.path.startsWith('/analysis/request/')) {
      final requestId = request.url.pathSegments.last;
      return http.Response(
        jsonEncode(<String, Object>{
          'request_id': requestId,
          'session_id': 'local-admin-hard',
          'completed_at': '2026-04-21T10:00:00Z',
          'classification': 'clean',
          'signals': <String>[],
          'attack_patterns': <String>[],
          'intent_summary': '',
          'event_count': 1,
          'suspicion_count': 0,
          'model_fail_count': 0,
        }),
        200,
      );
    }

    return http.Response('', 404);
  });
}
