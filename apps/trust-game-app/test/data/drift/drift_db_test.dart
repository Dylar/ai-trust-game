import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/core/user/user_profile.dart';
import '../../testing/test_user_profile.dart';
import 'package:app/data/analysis/drift_analysis_repository.dart';
import 'package:app/data/interaction/drift_interaction_repository.dart';
import 'package:app/data/drift/drift_db.dart';
import 'package:app/data/drift/drift_user_repository.dart';
import 'package:app/data/session/drift_session_repository.dart';
import 'package:app/models/analysis_models.dart';
import 'package:app/models/interaction_models.dart';
import 'package:app/models/session_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DriftDB database;

  setUp(() {
    database = DriftDB.forTest(migrations: [InitialDriftMigration()]);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'GIVEN Drift database configuration WHEN inspected THEN it uses timestamp versioning',
    () {
      expect(aiTrustGameDriftDatabaseName, 'aiTrustGameDriftDB');
      expect(database.schemaVersion, DriftDB.versions.last.version);
    },
  );

  test(
    'GIVEN a new Drift database WHEN opened THEN it creates all tables',
    () async {
      final rows = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name",
          )
          .get();

      final tableNames = rows.map((row) => row.read<String>('name')).toSet();

      expect(
        tableNames,
        containsAll(<String>{
          'interactions',
          'request_analyses',
          'session_analyses',
          'sessions',
          'users',
        }),
      );
      expect(tableNames, isNot(contains('selected_users')));
      expect(tableNames, isNot(contains('sync_metadata')));
    },
  );

  test(
    'GIVEN users WHEN sessions exist THEN loaded users are sorted by latest local activity',
    () async {
      final users = DriftUserRepository(database: database);

      await users.saveUser(
        UserProfile(
          id: 'older-user',
          displayName: 'Older User',
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );
      await users.saveUser(
        UserProfile(
          id: 'newer-user',
          displayName: 'Newer User',
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );
      await users.saveUser(
        UserProfile(
          id: 'alpha-user',
          displayName: 'Alpha User',
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );
      await users.saveUser(
        UserProfile(
          id: 'zulu-user',
          displayName: 'Zulu User',
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );
      await _insertSessionRow(
        database,
        userId: 'older-user',
        sessionId: 'session-older',
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      await _insertSessionRow(
        database,
        userId: 'newer-user',
        sessionId: 'session-newer',
        updatedAt: DateTime.utc(2026, 1, 2),
      );

      final loadedUsers = await users.listLoadedUsers();
      final unloadedUsers = await users.listUnloadedUsers();

      expect(loadedUsers.map((user) => user.id), <String>[
        'newer-user',
        'older-user',
      ]);
      expect(unloadedUsers.map((user) => user.id), <String>[
        'alpha-user',
        'zulu-user',
      ]);
      expect(loadedUsers.every((user) => user.isLoaded), isTrue);
      expect(unloadedUsers.every((user) => !user.isLoaded), isTrue);
    },
  );

  test(
    'GIVEN cached sessions WHEN listed for a user THEN only that user sessions are returned',
    () async {
      final userSessions = DriftSessionRepository(
        database: database,
        selectedUser: SelectedUserController(
          initialUser: testUserProfile('user-1'),
        ),
      );
      final otherSessions = DriftSessionRepository(
        database: database,
        selectedUser: SelectedUserController(
          initialUser: testUserProfile('user-2'),
        ),
      );

      await userSessions.saveSession(
        const Session(id: 'session-1', role: Role.employee, mode: Mode.medium),
      );
      await otherSessions.saveSession(
        const Session(id: 'session-2', role: Role.guest, mode: Mode.easy),
      );

      final sessions = await userSessions.listSessions();
      final session = await userSessions.getSession('session-1');

      expect(sessions.map((item) => item.id), <String>['session-1']);
      expect(session?.role, Role.employee);
      expect(await userSessions.getSession('session-2'), isNull);
    },
  );

  test(
    'GIVEN cached interactions WHEN listed for a session THEN they are read back in save order',
    () async {
      final interactions = DriftInteractionRepository(
        database: database,
        selectedUser: SelectedUserController(
          initialUser: testUserProfile('user-1'),
        ),
      );

      await interactions.saveInteraction(
        const Interaction(
          sessionId: 'session-1',
          interactionId: 'interaction-1',
          message: 'First',
          answer: 'First answer',
        ),
      );
      await interactions.saveInteraction(
        const Interaction(
          sessionId: 'session-1',
          interactionId: 'interaction-2',
          message: 'Second',
          answer: 'Second answer',
        ),
      );

      final saved = await interactions.listInteractions('session-1');
      final last = await interactions.getLastInteraction('session-1');

      expect(saved.map((item) => item.interactionId), <String>[
        'interaction-1',
        'interaction-2',
      ]);
      expect(last?.interactionId, 'interaction-2');
    },
  );

  test(
    'GIVEN cached analysis views WHEN read back THEN request and session analysis are restored',
    () async {
      final analysisRepository = DriftAnalysisRepository(
        database: database,
        selectedUser: SelectedUserController(
          initialUser: testUserProfile('user-1'),
        ),
      );
      final request = RequestAnalysis(
        requestId: 'request-1',
        sessionId: 'session-1',
        completedAt: DateTime.utc(2026, 1, 2),
        classification: 'suspicious',
        signals: const <String>['signal-a'],
        attackPatterns: const <String>['pattern-a'],
        intentSummary: 'Probe access.',
        eventCount: 3,
        suspicionCount: 2,
        modelFailCount: 1,
      );
      final session = SessionAnalysis(
        sessionId: 'session-1',
        classification: 'suspicious',
        signals: const <String>['session-signal'],
        attackPatterns: const <String>['session-pattern'],
        intentSummary: 'Session summary.',
        requestCount: 1,
        requests: <RequestAnalysis>[request],
        suspicionCount: 2,
        modelFailCount: 1,
      );

      await analysisRepository.saveSessionAnalysis(session);

      final savedRequest = await analysisRepository.getRequestAnalysis(
        'request-1',
      );
      final savedSession = await analysisRepository.getSessionAnalysis(
        'session-1',
      );

      expect(savedRequest?.signals, <String>['signal-a']);
      expect(savedRequest?.attackPatterns, <String>['pattern-a']);
      expect(savedSession?.classification, 'suspicious');
      expect(savedSession?.requests.single.requestId, 'request-1');
    },
  );
}

Future<void> _insertSessionRow(
  DriftDB database, {
  required String userId,
  required String sessionId,
  required DateTime updatedAt,
}) async {
  await database
      .into(database.sessionRows)
      .insert(
        SessionRowsCompanion.insert(
          id: sessionId,
          userId: userId,
          role: Role.admin.name,
          mode: Mode.hard.name,
          updatedAt: updatedAt,
        ),
      );
}
