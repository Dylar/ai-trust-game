import 'dart:convert';

import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/core/user/user_identity.dart';
import 'package:app/data/local/local_database.dart';
import 'package:app/data/local/local_user_repository.dart';
import 'package:app/data/session/drift_session_repository.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/services/startup_refresh_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late LocalDatabase database;
  late DriftLocalUserRepository userRepository;
  late DriftSessionRepository sessionRepository;

  setUp(() {
    database = LocalDatabase(NativeDatabase.memory());
    userRepository = DriftLocalUserRepository(database: database);
    sessionRepository = DriftSessionRepository(
      database: database,
      selectedUser: SelectedUserController(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'GIVEN known users WHEN startup refresh runs THEN sessions are cached per user',
    () async {
      await _saveKnownUser(userRepository, 'user-1');
      await _saveKnownUser(userRepository, 'user-2');
      final service = StartupRefreshServiceImpl(
        localUserRepository: userRepository,
        sessionApiClient: SessionApiClient(
          httpClient: MockClient((request) async {
            return http.Response(
              jsonEncode(<String, Object>{
                'sessions': <Object>[
                  <String, String>{
                    'sessionId': 'session-${request.headers['X-User-Id']}',
                    'userId': request.headers['X-User-Id']!,
                    'role': 'admin',
                    'mode': 'hard',
                    'createdAt': '2026-06-11T15:00:00Z',
                    'updatedAt': '2026-06-11T15:00:00Z',
                  },
                ],
              }),
              200,
            );
          }),
          apiBaseUri: Uri.parse('http://localhost:8080'),
          selectedUser: SelectedUserController(),
        ),
        sessionRepository: sessionRepository,
      );

      final result = await service.refreshKnownUsers();

      expect(result.status, StartupRefreshStatus.refreshed);
      expect(result.refreshedUserCount, 2);
      expect(result.refreshedSessionCount, 2);
      expect(
        await _sessionsForUser(database, 'user-1'),
        contains('session-user-1'),
      );
      expect(
        await _sessionsForUser(database, 'user-2'),
        contains('session-user-2'),
      );
    },
  );

  test(
    'GIVEN known users WHEN backend is unreachable THEN returns offline fallback',
    () async {
      await _saveKnownUser(userRepository, 'user-1');
      final service = StartupRefreshServiceImpl(
        localUserRepository: userRepository,
        sessionApiClient: SessionApiClient(
          httpClient: MockClient((_) async {
            throw http.ClientException('offline');
          }),
          apiBaseUri: Uri.parse('http://localhost:8080'),
          selectedUser: SelectedUserController(),
        ),
        sessionRepository: sessionRepository,
      );

      final result = await service.refreshKnownUsers();

      expect(result.status, StartupRefreshStatus.offlineFallback);
      expect(result.failedUserIds, <String>['user-1']);
    },
  );
}

Future<void> _saveKnownUser(
  DriftLocalUserRepository repository,
  String userId,
) async {
  await repository.saveKnownUser(
    KnownUser(
      id: userId,
      displayName: userId,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  );
}

Future<List<String>> _sessionsForUser(
  LocalDatabase database,
  String userId,
) async {
  final selectedUser = SelectedUserController(
    initialUser: UserIdentity(id: userId),
  );
  final repository = DriftSessionRepository(
    database: database,
    selectedUser: selectedUser,
  );
  final sessions = await repository.listSessions();
  return sessions.map((session) => session.id).toList(growable: false);
}
