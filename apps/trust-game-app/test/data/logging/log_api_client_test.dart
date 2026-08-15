import 'dart:convert';
import 'dart:io';

import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/selected_user_controller.dart';
import '../../testing/test_user_profile.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/data/logging/log_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final selectedUser = SelectedUserController(
    initialUser: testUserProfile('user-123'),
  );

  test('posts log JSON with user and optional session headers', () async {
    late http.Request capturedRequest;
    final client = LogApiClient(
      httpClient: MockClient((request) async {
        capturedRequest = request;
        return http.Response('', HttpStatus.accepted);
      }),
      apiBaseUri: Uri.parse('http://localhost:8080'),
      selectedUser: selectedUser,
    );

    await client.sendLog(
      AppLogEvent(
        level: AppLogLevel.warning,
        category: 'interaction',
        message: 'Send failed',
        sessionId: 'session-1',
        attributes: const <String, Object?>{'retryable': true},
      ),
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/logs/client');
    expect(capturedRequest.headers['Content-Type'], 'application/json');
    expect(capturedRequest.headers['X-User-Id'], 'user-123');
    expect(capturedRequest.headers['X-Session-Id'], 'session-1');
    expect(jsonDecode(capturedRequest.body), <String, Object?>{
      'level': 'WARN',
      'category': 'interaction',
      'message': 'Send failed',
      'attributes': <String, Object?>{'retryable': true},
    });
  });

  test('omits session header when no session context is provided', () async {
    late http.Request capturedRequest;
    final client = LogApiClient(
      httpClient: MockClient((request) async {
        capturedRequest = request;
        return http.Response('', HttpStatus.accepted);
      }),
      apiBaseUri: Uri.parse('http://localhost:8080'),
      selectedUser: selectedUser,
    );

    await client.sendLog(
      AppLogEvent(
        level: AppLogLevel.info,
        category: 'navigation',
        message: 'Opened home',
      ),
    );

    expect(capturedRequest.headers['X-User-Id'], 'user-123');
    expect(capturedRequest.headers.containsKey('X-Session-Id'), isFalse);
  });

  test('throws log api exception when backend rejects the request', () async {
    final client = LogApiClient(
      httpClient: MockClient((_) async {
        return http.Response(
          jsonEncode(<String, Object>{
            'error': <String, String>{'code': 'invalid_json'},
          }),
          HttpStatus.badRequest,
        );
      }),
      apiBaseUri: Uri.parse('http://localhost:8080'),
      selectedUser: selectedUser,
    );

    expect(
      () => client.sendLog(
        AppLogEvent(
          level: AppLogLevel.error,
          category: 'interaction',
          message: 'failed',
        ),
      ),
      throwsA(
        isA<LogApiException>()
            .having(
              (error) => error.statusCode,
              'statusCode',
              HttpStatus.badRequest,
            )
            .having((error) => error.code, 'code', ApiErrorCode.invalidJson),
      ),
    );
  });

  test('uses anonymous user header before user selection', () async {
    late http.Request capturedRequest;
    final client = LogApiClient(
      httpClient: MockClient((request) async {
        capturedRequest = request;
        return http.Response('', HttpStatus.accepted);
      }),
      apiBaseUri: Uri.parse('http://localhost:8080'),
      selectedUser: SelectedUserController(),
    );

    await client.sendLog(
      AppLogEvent(
        level: AppLogLevel.info,
        category: 'startup',
        message: 'Opened app',
      ),
    );

    expect(capturedRequest.headers['X-User-Id'], 'anonymous');
  });
}
