import 'dart:convert';

import 'package:app/data/api/api_error.dart';
import 'package:app/data/api/api_transport.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('parses success JSON for status 200', () {
    final json = parseJsonResponse(
      http.Response(jsonEncode(<String, String>{'value': 'ok'}), 200),
    );

    expect(json, <String, String>{'value': 'ok'});
  });

  test('throws ApiException with error code for non-200 error envelope', () {
    final response = http.Response(
      jsonEncode(<String, Object>{
        'error': <String, String>{'code': 'session_not_found'},
      }),
      404,
    );

    expect(
      () => parseJsonResponse(response),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 404)
            .having(
              (error) => error.code,
              'code',
              ApiErrorCode.sessionNotFound,
            ),
      ),
    );
  });

  test('throws ApiException without error code for malformed error body', () {
    expect(
      () => parseJsonResponse(http.Response('', 500)),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 500)
            .having((error) => error.code, 'code', isNull),
      ),
    );
  });

  test('maps client exceptions to backend unreachable', () async {
    final client = MockClient((_) async {
      throw http.ClientException('connection refused');
    });

    await expectLater(
      sendGetRequest(client, Uri.parse('http://localhost/test')),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', isNull)
            .having(
              (error) => error.code,
              'code',
              ApiErrorCode.backendUnreachable,
            ),
      ),
    );
  });

  test('maps timeouts to request timeout', () async {
    final client = MockClient((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return http.Response('', 200);
    });

    await expectLater(
      sendGetRequest(
        client,
        Uri.parse('http://localhost/test'),
        timeout: const Duration(milliseconds: 1),
      ),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', isNull)
            .having((error) => error.code, 'code', ApiErrorCode.requestTimeout),
      ),
    );
  });
}
