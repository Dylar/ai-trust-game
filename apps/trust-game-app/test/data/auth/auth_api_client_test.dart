import 'dart:convert';

import 'package:app/data/api/api_error.dart';
import 'package:app/data/auth/auth_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'GIVEN auth backend users WHEN listing users THEN returns profiles',
    () async {
      late http.Request capturedRequest;
      final client = AuthApiClient(
        httpClient: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode(<String, Object>{
              'users': <Object>[
                <String, String>{
                  'userId': 'user-1',
                  'displayName': 'Alice',
                  'createdAt': '2026-06-11T10:00:00Z',
                  'updatedAt': '2026-06-11T10:00:00Z',
                },
              ],
            }),
            200,
          );
        }),
        apiBaseUri: Uri.parse('http://localhost:8080'),
      );

      final users = await client.listUsers();

      expect(capturedRequest.method, 'GET');
      expect(capturedRequest.url.path, '/auth/users');
      expect(users.single.id, 'user-1');
      expect(users.single.displayName, 'Alice');
    },
  );

  test(
    'GIVEN display name WHEN creating user THEN posts auth request',
    () async {
      late http.Request capturedRequest;
      final client = AuthApiClient(
        httpClient: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode(<String, String>{
              'userId': 'user-2',
              'displayName': 'Bob',
              'createdAt': '2026-06-11T10:00:00Z',
              'updatedAt': '2026-06-11T10:00:00Z',
            }),
            201,
          );
        }),
        apiBaseUri: Uri.parse('http://localhost:8080'),
      );

      final user = await client.createUser('Bob');

      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url.path, '/auth/users');
      expect(capturedRequest.headers['Content-Type'], 'application/json');
      expect(jsonDecode(capturedRequest.body), <String, String>{
        'displayName': 'Bob',
      });
      expect(user.id, 'user-2');
    },
  );

  test(
    'GIVEN backend error WHEN creating user THEN throws auth api exception',
    () {
      final client = AuthApiClient(
        httpClient: MockClient((_) async {
          return http.Response(
            jsonEncode(<String, Object>{
              'error': <String, String>{'code': 'duplicate_user_display_name'},
            }),
            409,
          );
        }),
        apiBaseUri: Uri.parse('http://localhost:8080'),
      );

      expect(
        () => client.createUser('Alice'),
        throwsA(
          isA<AuthApiException>()
              .having((error) => error.statusCode, 'statusCode', 409)
              .having(
                (error) => error.code,
                'code',
                ApiErrorCode.duplicateUserDisplayName,
              ),
        ),
      );
    },
  );
}
