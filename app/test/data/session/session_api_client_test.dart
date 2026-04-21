import 'dart:convert';

import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/start_session_dto.dart';
import 'package:app/models/session_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('posts session start JSON to the backend', () async {
    late http.Request capturedRequest;
    final client = SessionApiClient(
      httpClient: MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode(<String, String>{
            'sessionId': 'session-1',
            'role': 'admin',
            'mode': 'hard',
          }),
          200,
        );
      }),
      apiBaseUri: Uri.parse('http://localhost:8080'),
    );

    final response = await client.startSession(
      const StartSessionRequest(role: Role.admin, mode: Mode.hard),
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/session/start');
    expect(capturedRequest.headers['Content-Type'], 'application/json');
    expect(jsonDecode(capturedRequest.body), <String, String>{
      'role': 'admin',
      'mode': 'hard',
    });
    expect(response.sessionId, 'session-1');
    expect(response.role, Role.admin);
    expect(response.mode, Mode.hard);
  });
}
