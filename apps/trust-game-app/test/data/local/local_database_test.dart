import 'package:app/data/analysis/drift_analysis_repository.dart';
import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/core/user/user_identity.dart';
import 'package:app/data/interaction/drift_interaction_repository.dart';
import 'package:app/data/local/local_database.dart';
import 'package:app/data/local/local_user_repository.dart';
import 'package:app/data/session/drift_session_repository.dart';
import 'package:app/models/analysis_models.dart';
import 'package:app/models/interaction_models.dart';
import 'package:app/models/session_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalDatabase database;

  setUp(() {
    database = LocalDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'GIVEN a new local database WHEN opened THEN it creates all tables',
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
          'selected_users',
          'sync_metadata',
          'users',
        }),
      );
    },
  );

  test(
    'GIVEN known users WHEN one has a cached session THEN loaded and unloaded lists are derived locally',
    () async {
      final users = DriftLocalUserRepository(database: database);
      final selectedUser = SelectedUserController(
        initialUser: const UserIdentity(id: 'loaded-user'),
      );
      final sessions = DriftSessionRepository(
        database: database,
        selectedUser: selectedUser,
      );

      await users.saveKnownUser(
        KnownUser(
          id: 'loaded-user',
          displayName: 'Loaded User',
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
          lastSelectedAt: DateTime.utc(2026, 1, 2),
        ),
      );
      await users.saveKnownUser(
        KnownUser(
          id: 'unloaded-user',
          displayName: 'Unloaded User',
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
          lastSelectedAt: DateTime.utc(2026, 1, 1),
        ),
      );
      await sessions.saveSession(
        const Session(id: 'session-1', role: Role.admin, mode: Mode.hard),
      );

      final loadedUsers = await users.listLoadedUsers();
      final unloadedUsers = await users.listUnloadedUsers();

      expect(loadedUsers.map((user) => user.id), <String>['loaded-user']);
      expect(unloadedUsers.map((user) => user.id), <String>['unloaded-user']);
      expect(loadedUsers.single.isLoaded, isTrue);
      expect(unloadedUsers.single.isLoaded, isFalse);
    },
  );

  test(
    'GIVEN known users WHEN a user is selected THEN selected user state is stored locally',
    () async {
      final users = DriftLocalUserRepository(database: database);

      await users.saveKnownUser(
        KnownUser(
          id: 'user-1',
          displayName: 'User One',
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );

      await users.selectUser('user-1');

      final selectedUser = await users.getSelectedUser();

      expect(selectedUser?.id, 'user-1');
      expect(selectedUser?.displayName, 'User One');
      expect(selectedUser?.lastSelectedAt, isNotNull);
    },
  );

  test(
    'GIVEN cached sessions WHEN listed for a user THEN only that user sessions are returned',
    () async {
      final userSessions = DriftSessionRepository(
        database: database,
        selectedUser: SelectedUserController(
          initialUser: const UserIdentity(id: 'user-1'),
        ),
      );
      final otherSessions = DriftSessionRepository(
        database: database,
        selectedUser: SelectedUserController(
          initialUser: const UserIdentity(id: 'user-2'),
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
          initialUser: const UserIdentity(id: 'user-1'),
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
          initialUser: const UserIdentity(id: 'user-1'),
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
