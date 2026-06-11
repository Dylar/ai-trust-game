import 'dart:convert';

import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:app/data/auth/auth_api_client.dart';
import 'package:app/data/drift/drift_user_repository.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../testing/mocks/recording_app_log_sink.dart';
import '../testing/test_user_profile.dart';

void main() {
  test(
    'GIVEN existing user WHEN selecting user THEN stores selected user in controller',
    () async {
      final selectedUser = SelectedUserController();
      final service = AuthServiceImpl(
        appLogger: _silentLogger,
        userRepository: _FakeUserRepository(),
        selectedUser: selectedUser,
      );
      final user = testUserProfile('selected-user');

      service.selectUser(user);

      expect(selectedUser.value, user);
    },
  );

  test(
    'GIVEN display name WHEN creating user THEN saves and selects backend user',
    () async {
      final repository = _FakeUserRepository();
      final selectedUser = SelectedUserController();
      final service = AuthServiceImpl(
        appLogger: _silentLogger,
        userRepository: repository,
        selectedUser: selectedUser,
        apiClient: AuthApiClient(
          httpClient: MockClient((request) async {
            return http.Response(
              jsonEncode(<String, String>{
                'userId': 'backend-user',
                'displayName': 'Alice Example',
                'createdAt': '2026-06-11T10:00:00Z',
                'updatedAt': '2026-06-11T10:00:00Z',
              }),
              201,
            );
          }),
          apiBaseUri: Uri.parse('http://localhost:8080'),
        ),
      );

      final user = await service.createUser(' Alice Example ');

      expect(user.id, 'backend-user');
      expect(user.displayName, 'Alice Example');
      expect(repository.savedUsers, <UserProfile>[user]);
      expect(selectedUser.value, user);
    },
  );

  test(
    'GIVEN backend users WHEN loading users THEN mirrors users into local repository',
    () async {
      final repository = _FakeUserRepository();
      final service = AuthServiceImpl(
        appLogger: _silentLogger,
        userRepository: repository,
        selectedUser: SelectedUserController(),
        apiClient: AuthApiClient(
          httpClient: MockClient((_) async {
            return http.Response(
              jsonEncode(<String, Object>{
                'users': <Object>[
                  <String, String>{
                    'userId': 'backend-user',
                    'displayName': 'Backend User',
                    'createdAt': '2026-06-11T10:00:00Z',
                    'updatedAt': '2026-06-11T10:00:00Z',
                  },
                ],
              }),
              200,
            );
          }),
          apiBaseUri: Uri.parse('http://localhost:8080'),
        ),
      );

      await service.loadUserProfiles();

      expect(repository.savedUsers.single.id, 'backend-user');
    },
  );

  test(
    'GIVEN unreachable backend WHEN loading users THEN logs local fallback',
    () async {
      final sink = RecordingAppLogSink();
      final service = AuthServiceImpl(
        appLogger: AppLogger(sinks: <AppLogSink>[sink]),
        userRepository: _FakeUserRepository(),
        selectedUser: SelectedUserController(),
        apiClient: AuthApiClient(
          httpClient: MockClient((_) async {
            throw http.ClientException('offline');
          }),
          apiBaseUri: Uri.parse('http://localhost:8080'),
        ),
      );

      await service.loadUserProfiles();

      expect(sink.events, hasLength(1));
      expect(sink.events.single.level, AppLogLevel.warning);
      expect(sink.events.single.category, 'auth');
      expect(
        sink.events.single.message,
        'User profile load used local fallback',
      );
      expect(sink.events.single.attributes['errorCode'], 'backend_unreachable');
    },
  );

  test(
    'GIVEN missing backend WHEN creating user THEN fails without local fallback',
    () async {
      final selectedUser = SelectedUserController();
      final service = AuthServiceImpl(
        appLogger: _silentLogger,
        userRepository: _FakeUserRepository(),
        selectedUser: selectedUser,
        apiClient: AuthApiClient(
          httpClient: MockClient((_) async {
            throw http.ClientException('offline');
          }),
          apiBaseUri: Uri.parse('http://localhost:8080'),
        ),
      );
      await expectLater(
        service.createUser('Alice'),
        throwsA(isA<AuthApiException>()),
      );
      expect(selectedUser.value, isNull);
    },
  );
}

class _FakeUserRepository implements UserRepository {
  final savedUsers = <UserProfile>[];

  @override
  Future<List<UserProfile>> listLoadedUsers() async => <UserProfile>[];

  @override
  Future<List<UserProfile>> listUnloadedUsers() async {
    return savedUsers;
  }

  @override
  Future<List<UserProfile>> listUsers() async {
    return savedUsers;
  }

  @override
  Future<void> saveUser(UserProfile user) async {
    savedUsers.add(user);
  }
}

const _silentLogger = AppLogger(sinks: <AppLogSink>[]);
