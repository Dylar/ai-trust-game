import 'dart:convert';

import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/analysis/drift_analysis_repository.dart';
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
  late DriftAnalysisRepository analysisRepository;
  late DriftInteractionRepository interactionRepository;
  late DriftUserRepository userRepository;
  late DriftSessionRepository sessionRepository;

  setUp(() {
    database = DriftDB.forTest(migrations: [InitialDriftMigration()]);
    analysisRepository = DriftAnalysisRepository(
      database: database,
      selectedUser: SelectedUserController(),
    );
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
    'GIVEN loaded users WHEN sync runs THEN sessions interactions and analyses are cached per user',
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
            200,
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
            200,
          );
        }

        if (request.url.path.startsWith('/analysis/session/')) {
          return http.Response(
            jsonEncode(<String, Object>{
              'session_id': request.url.pathSegments.last,
              'classification': 'suspicious',
              'signals': <String>['prompt-injection'],
              'attack_patterns': <String>['secret-extraction'],
              'intent_summary': 'Session looked suspicious.',
              'request_count': 1,
              'suspicion_count': 1,
              'model_fail_count': 0,
              'requests': <Object>[],
            }),
            200,
          );
        }

        if (request.url.path.startsWith('/analysis/request/')) {
          return http.Response(
            jsonEncode(<String, Object>{
              'request_id': request.url.pathSegments.last,
              'session_id': 'session-${request.headers['X-User-Id']}',
              'completed_at': '2026-06-11T15:00:01Z',
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
        }

        return http.Response('not found', 404);
      });
      final service = SyncServiceImpl(
        appLogger: _silentLogger,
        analysisApiClient: AnalysisApiClient(
          httpClient: httpClient,
          apiBaseUri: Uri.parse('http://localhost:8080'),
          selectedUser: SelectedUserController(),
        ),
        analysisRepository: analysisRepository,
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

      final result = await service.syncLoadedUsers();

      expect(result.status, SyncStatus.refreshed);
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
      expect(
        await _interactionsForUser(database, 'user-1', 'session-user-1'),
        contains('request-user-1'),
      );
      expect(
        await _interactionsForUser(database, 'user-2', 'session-user-2'),
        contains('request-user-2'),
      );
      expect(
        await _sessionAnalysisForUser(database, 'user-1', 'session-user-1'),
        'suspicious',
      );
      expect(
        await _requestAnalysisForUser(database, 'user-1', 'request-user-1'),
        'clean',
      );
    },
  );

  test(
    'GIVEN loaded users WHEN backend is unreachable THEN returns offline fallback',
    () async {
      await _saveUser(userRepository, 'user-1');
      await _saveLoadedSession(sessionRepository, 'user-1');
      final sink = RecordingAppLogSink();
      final httpClient = MockClient((_) async {
        throw http.ClientException('offline');
      });
      final service = SyncServiceImpl(
        appLogger: AppLogger(sinks: <AppLogSink>[sink]),
        analysisApiClient: AnalysisApiClient(
          httpClient: httpClient,
          apiBaseUri: Uri.parse('http://localhost:8080'),
          selectedUser: SelectedUserController(),
        ),
        analysisRepository: analysisRepository,
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

      final result = await service.syncLoadedUsers();

      expect(result.status, SyncStatus.offlineFallback);
      expect(result.failedUserIds, <String>['user-1']);
      expect(sink.events, hasLength(1));
      expect(sink.events.single.category, 'sync');
      expect(sink.events.single.message, 'User sync failed');
      expect(sink.events.single.attributes, <String, Object?>{
        'userId': 'user-1',
        'syncStatus': 'offlineFallback',
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

Future<String?> _sessionAnalysisForUser(
  DriftDB database,
  String userId,
  String sessionId,
) async {
  final selectedUser = SelectedUserController(
    initialUser: testUserProfile(userId),
  );
  final repository = DriftAnalysisRepository(
    database: database,
    selectedUser: selectedUser,
  );
  final analysis = await repository.getSessionAnalysis(sessionId);
  return analysis?.classification;
}

Future<String?> _requestAnalysisForUser(
  DriftDB database,
  String userId,
  String requestId,
) async {
  final selectedUser = SelectedUserController(
    initialUser: testUserProfile(userId),
  );
  final repository = DriftAnalysisRepository(
    database: database,
    selectedUser: selectedUser,
  );
  final analysis = await repository.getRequestAnalysis(requestId);
  return analysis?.classification;
}
