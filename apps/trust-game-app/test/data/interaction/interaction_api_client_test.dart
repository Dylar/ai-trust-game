import 'dart:convert';

import 'package:app/data/api/api_error.dart';
import 'package:app/data/interaction/interaction_api_client.dart';
import 'package:app/data/interaction/interaction_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('posts interaction JSON with session header to the backend', () async {
    late http.Request capturedRequest;
    final client = InteractionApiClient(
      httpClient: MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode(<String, String>{'message': 'No.'}),
          200,
          headers: const <String, String>{'x-request-id': 'request-1'},
        );
      }),
      apiBaseUri: Uri.parse('http://localhost:8080'),
      userId: 'user-123',
    );

    final response = await client.createInteraction(
      const InteractionRequest(
        sessionId: 'session-1',
        message: 'Can I access the vault?',
      ),
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/interaction');
    expect(capturedRequest.headers['Content-Type'], 'application/json');
    expect(capturedRequest.headers['X-Session-Id'], 'session-1');
    expect(capturedRequest.headers['X-User-Id'], 'user-123');
    expect(jsonDecode(capturedRequest.body), <String, String>{
      'message': 'Can I access the vault?',
    });
    expect(response.sessionId, 'session-1');
    expect(response.interactionId, 'request-1');
    expect(response.message, 'Can I access the vault?');
    expect(response.answer, 'No.');
  });

  test('throws interaction exception with backend error code', () async {
    final client = InteractionApiClient(
      httpClient: MockClient((_) async {
        return http.Response(
          jsonEncode(<String, Object>{
            'error': <String, String>{'code': 'session_not_found'},
          }),
          404,
        );
      }),
      apiBaseUri: Uri.parse('http://localhost:8080'),
      userId: 'user-123',
    );

    expect(
      () => client.createInteraction(
        const InteractionRequest(sessionId: 'missing', message: 'Hello'),
      ),
      throwsA(
        isA<InteractionApiException>()
            .having((error) => error.statusCode, 'statusCode', 404)
            .having(
              (error) => error.code,
              'code',
              ApiErrorCode.sessionNotFound,
            ),
      ),
    );
  });
}
