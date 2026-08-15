import 'dart:convert';
import 'dart:io';

import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:app/data/interaction/drift_interaction_repository.dart';
import 'package:app/data/interaction/interaction_api_client.dart';
import 'package:app/data/drift/drift_db.dart';
import 'package:app/data/drift/drift_user_repository.dart';
import 'package:app/data/session/drift_session_repository.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/models/session_models.dart';
import 'package:app/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../testing/mocks/recording_app_log_sink.dart';
import '../testing/test_user_profile.dart';

void main() {
  late DriftDB database;
  late DriftInteractionRepository interactionRepository;
  late DriftUserRepository userRepository;
  late DriftSessionRepository sessionRepository;

  setUp(() {
    database = DriftDB.forTest(migrations: [InitialDriftMigration()]);
    interactionRepository = DriftInteractionRepository(
      database: database,
      selectedUser: SelectedUserController(),
    );
    userRepository = DriftUserRepository(database: database);
    sessionRepository = DriftSessionRepository(
      database: database,
      selectedUser: SelectedUserController(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'GIVEN loaded users WHEN sync runs THEN sessions and interactions are cached per user',
    () async {
      await _saveUser(userRepository, 'user-1');
      await _saveUser(userRepository, 'user-2');
      await _saveLoadedSession(sessionRepository, 'user-1');
      await _saveLoadedSession(sessionRepository, 'user-2');
      final httpClient = MockClient((request) async {
        if (request.url.path == '/session/list') {
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
            HttpStatus.ok,
          );
        }

        if (request.url.path.startsWith('/interaction/session/')) {
          return http.Response(
            jsonEncode(<String, Object>{
              'interactions': <Object>[
                <String, String>{
                  'interactionId': 'interaction-1',
                  'sessionId': request.url.pathSegments.last,
                  'requestId': 'request-${request.headers['X-User-Id']}',
                  'message': 'Cached message',
                  'answer': 'Cached answer',
                  'createdAt': '2026-06-11T15:00:00Z',
                },
              ],
            }),
            HttpStatus.ok,
          );
        }

        return http.Response('not found', HttpStatus.notFound);
      });
      final service = SyncService(
        appLogger: _silentLogger,
        interactionApiClient: InteractionApiClient(
          httpClient: httpClient,
          apiBaseUri: Uri.parse('http://localhost:8080'),
          selectedUser: SelectedUserController(),
        ),
        interactionRepository: interactionRepository,
        userRepository: userRepository,
        sessionApiClient: SessionApiClient(
          httpClient: httpClient,
          apiBaseUri: Uri.parse('http://localhost:8080'),
          selectedUser: SelectedUserController(),
        ),
        sessionRepository: sessionRepository,
      );

      final result = await service.syncStartup();

      expect(result.status, SyncStatus.synced);
      expect(
        await _sessionsForUser(database, 'user-1'),
        contains('session-user-1'),
      );
      expect(
        await _sessionsForUser(database, 'user-2'),
        contains('session-user-2'),
      );
      expect(
        await _interactionsForUser(database, 'user-1', 'session-user-1'),
        contains('request-user-1'),
      );
      expect(
        await _interactionsForUser(database, 'user-2', 'session-user-2'),
        contains('request-user-2'),
      );
    },
  );

  test(
    'GIVEN existing local session WHEN user sync runs THEN keeps local history and adds backend sessions',
    () async {
      await _saveUser(userRepository, 'user-1');
      await _saveLoadedSession(sessionRepository, 'user-1');
      final httpClient = MockClient((request) async {
        if (request.url.path == '/session/list') {
          return http.Response(
            jsonEncode(<String, Object>{
              'sessions': <Object>[
                <String, String>{
                  'sessionId': 'session-user-1',
                  'userId': 'user-1',
                  'role': 'admin',
                  'mode': 'hard',
                  'createdAt': '2026-06-11T15:00:00Z',
                  'updatedAt': '2026-06-11T15:00:00Z',
                },
              ],
            }),
            HttpStatus.ok,
          );
        }

        if (request.url.path.startsWith('/interaction/session/')) {
          return http.Response(
            jsonEncode(<String, Object>{'interactions': <Object>[]}),
            HttpStatus.ok,
          );
        }

        return http.Response('not found', HttpStatus.notFound);
      });
      final service = SyncService(
        appLogger: _silentLogger,
        interactionApiClient: InteractionApiClient(
          httpClient: httpClient,
          apiBaseUri: Uri.parse('http://localhost:8080'),
          selectedUser: SelectedUserController(),
        ),
        interactionRepository: interactionRepository,
        userRepository: userRepository,
        sessionApiClient: SessionApiClient(
          httpClient: httpClient,
          apiBaseUri: Uri.parse('http://localhost:8080'),
          selectedUser: SelectedUserController(),
        ),
        sessionRepository: sessionRepository,
      );

      final result = await service.syncUserRestore(testUserProfile('user-1'));

      expect(result.status, SyncStatus.synced);
      expect(
        await _sessionsForUser(database, 'user-1'),
        containsAll(<String>['loaded-session-user-1', 'session-user-1']),
      );
    },
  );

  test(
    'GIVEN loaded users WHEN backend is unreachable THEN returns failed sync',
    () async {
      await _saveUser(userRepository, 'user-1');
      await _saveLoadedSession(sessionRepository, 'user-1');
      final sink = RecordingAppLogSink();
      final httpClient = MockClient((_) async {
        throw http.ClientException('offline');
      });
      final service = SyncService(
        appLogger: AppLogger(sinks: <AppLogSink>[sink]),
        interactionApiClient: InteractionApiClient(
          httpClient: httpClient,
          apiBaseUri: Uri.parse('http://localhost:8080'),
          selectedUser: SelectedUserController(),
        ),
        interactionRepository: interactionRepository,
        userRepository: userRepository,
        sessionApiClient: SessionApiClient(
          httpClient: httpClient,
          apiBaseUri: Uri.parse('http://localhost:8080'),
          selectedUser: SelectedUserController(),
        ),
        sessionRepository: sessionRepository,
      );

      final result = await service.syncStartup();

      expect(result.status, SyncStatus.failed);
      expect(sink.events, hasLength(1));
      expect(sink.events.single.category, 'sync');
      expect(sink.events.single.message, 'User sync failed');
      expect(sink.events.single.attributes, <String, Object?>{
        'userId': 'user-1',
        'syncStatus': 'failed',
        'httpStatusCode': null,
        'errorCode': 'backend_unreachable',
      });
    },
  );
}

const _silentLogger = AppLogger(sinks: <AppLogSink>[]);

Future<void> _saveUser(DriftUserRepository repository, String userId) async {
  await repository.saveUser(
    UserProfile(
      id: userId,
      displayName: userId,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  );
}

Future<void> _saveLoadedSession(
  DriftSessionRepository repository,
  String userId,
) async {
  await repository.saveSessionForUser(
    userId: userId,
    session: Session(
      id: 'loaded-session-$userId',
      role: Role.admin,
      mode: Mode.hard,
    ),
  );
}

Future<List<String>> _sessionsForUser(DriftDB database, String userId) async {
  final selectedUser = SelectedUserController(
    initialUser: testUserProfile(userId),
  );
  final repository = DriftSessionRepository(
    database: database,
    selectedUser: selectedUser,
  );
  final sessions = await repository.listSessions();
  return sessions.map((session) => session.id).toList(growable: false);
}

Future<List<String>> _interactionsForUser(
  DriftDB database,
  String userId,
  String sessionId,
) async {
  final selectedUser = SelectedUserController(
    initialUser: testUserProfile(userId),
  );
  final repository = DriftInteractionRepository(
    database: database,
    selectedUser: selectedUser,
  );
  final interactions = await repository.listInteractions(sessionId);
  return interactions
      .map((interaction) => interaction.interactionId)
      .toList(growable: false);
}
