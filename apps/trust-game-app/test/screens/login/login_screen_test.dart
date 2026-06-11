import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:app/data/drift/drift_user_repository.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/screens/home/home_keys.dart';
import 'package:app/screens/home/home_screen.dart';
import 'package:app/screens/home/home_view_model.dart';
import 'package:app/screens/login/login_keys.dart';
import 'package:app/screens/login/login_screen.dart';
import 'package:app/screens/login/login_view_model.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/mocks/recording_app_log_sink.dart';
import '../../testing/test_user_profile.dart';

void main() {
  testWidgets(
    'GIVEN loaded and unloaded users WHEN login screen opens THEN shows both user lists',
    (tester) async {
      final authService = _FakeAuthService();
      final userRepository = _FakeUserRepository(
        loadedUsers: <UserProfile>[_loadedUserProfile('loaded-user')],
        unloadedUsers: <UserProfile>[testUserProfile('unloaded-user')],
      );

      await _pumpLoginScreen(
        tester,
        authService: authService,
        userRepository: userRepository,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(LoginKeys.loadedUsersSection), findsOneWidget);
      expect(find.byKey(LoginKeys.unloadedUsersSection), findsOneWidget);
      expect(find.byKey(LoginKeys.user('loaded-user')), findsOneWidget);
      expect(find.byKey(LoginKeys.user('unloaded-user')), findsOneWidget);
    },
  );

  testWidgets('GIVEN existing user WHEN selecting user THEN logs in', (
    tester,
  ) async {
    final user = _loadedUserProfile('loaded-user');
    final authService = _FakeAuthService();
    final userRepository = _FakeUserRepository(
      loadedUsers: <UserProfile>[user],
    );

    await _pumpLoginScreen(
      tester,
      authService: authService,
      userRepository: userRepository,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(LoginKeys.user('loaded-user')));
    await tester.pumpAndSettle();

    expect(authService.selectedUser, user);
    expect(find.byKey(HomeKeys.screen), findsOneWidget);
  });

  testWidgets(
    'GIVEN sync exception WHEN selecting user THEN logs and shows error dialog',
    (tester) async {
      final user = testUserProfile('unloaded-user');
      final authService = _FakeAuthService();
      final syncService = _FakeSyncService(shouldFailSyncUser: true);
      final sink = RecordingAppLogSink();
      final userRepository = _FakeUserRepository(
        unloadedUsers: <UserProfile>[user],
      );

      await _pumpLoginScreen(
        tester,
        authService: authService,
        userRepository: userRepository,
        syncService: syncService,
        appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(LoginKeys.user('unloaded-user')));
      await tester.pumpAndSettle();

      expect(authService.selectedUser, isNull);
      expect(syncService.syncedUser, user);
      expect(sink.events, hasLength(1));
      expect(sink.events.single.category, 'login');
      expect(sink.events.single.message, 'Login user selection failed');
      expect(sink.events.single.attributes['userId'], 'unloaded-user');
      expect(
        find.text('The selected user could not be loaded.'),
        findsOneWidget,
      );
      expect(find.byKey(LoginKeys.screen), findsOneWidget);
    },
  );

  testWidgets(
    'GIVEN display name WHEN creating user THEN creates user and logs in',
    (tester) async {
      final authService = _FakeAuthService();
      final userRepository = _FakeUserRepository();

      await _pumpLoginScreen(
        tester,
        authService: authService,
        userRepository: userRepository,
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(LoginKeys.displayNameInput), 'Alice');
      await tester.tap(find.byKey(LoginKeys.createUserButton));
      await tester.pumpAndSettle();

      expect(authService.createdDisplayName, 'Alice');
      expect(find.byKey(HomeKeys.screen), findsOneWidget);
    },
  );

  testWidgets(
    'GIVEN empty display name WHEN creating user THEN stays on login screen',
    (tester) async {
      final authService = _FakeAuthService();
      final userRepository = _FakeUserRepository();

      await _pumpLoginScreen(
        tester,
        authService: authService,
        userRepository: userRepository,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(LoginKeys.createUserButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a display name before creating a user.'),
        findsOneWidget,
      );
      expect(authService.createdDisplayName, isNull);
      expect(find.byKey(LoginKeys.screen), findsOneWidget);
    },
  );

  testWidgets(
    'GIVEN unreachable backend WHEN creating user THEN shows error dialog',
    (tester) async {
      final authService = _FakeAuthService(shouldFailCreate: true);
      final sink = RecordingAppLogSink();
      final userRepository = _FakeUserRepository();

      await _pumpLoginScreen(
        tester,
        authService: authService,
        userRepository: userRepository,
        appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(LoginKeys.displayNameInput), 'Alice');
      await tester.tap(find.byKey(LoginKeys.createUserButton));
      await tester.pumpAndSettle();

      expect(
        find.text('The backend is not reachable or rejected the new user.'),
        findsOneWidget,
      );
      expect(sink.events, hasLength(1));
      expect(sink.events.single.category, 'login');
      expect(sink.events.single.message, 'Login user creation failed');
      expect(sink.events.single.attributes['displayNameLength'], 5);
      expect(authService.createdDisplayName, isNull);
      expect(find.byKey(LoginKeys.screen), findsOneWidget);
    },
  );
}

Future<void> _pumpLoginScreen(
  WidgetTester tester, {
  required AuthService authService,
  required UserRepository userRepository,
  AppLogger appLogger = _silentLogger,
  SyncService? syncService,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: LoginScreen.routeName,
      onGenerateRoute: (settings) {
        if (settings.name == LoginScreen.routeName) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => LoginScreen(
              viewModel: LoginViewModel(
                appLogger: appLogger,
                authService: authService,
                userRepository: userRepository,
                syncService: syncService ?? _FakeSyncService(),
              ),
            ),
          );
        }
        if (settings.name == HomeScreen.routeName) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => HomeScreen(
              viewModel: HomeViewModel(
                interactionRepository: InMemoryInteractionRepository(),
                sessionRepository: InMemorySessionRepository(),
              ),
            ),
          );
        }
        return null;
      },
    ),
  );
}

const _silentLogger = AppLogger(sinks: <AppLogSink>[]);

class _FakeAuthService implements AuthService {
  _FakeAuthService({this.shouldFailCreate = false});

  final bool shouldFailCreate;
  UserProfile? selectedUser;
  String? createdDisplayName;

  @override
  Future<void> loadUserProfiles() async {}

  @override
  void selectUser(UserProfile user) {
    selectedUser = user;
  }

  @override
  Future<UserProfile> createUser(String displayName) async {
    if (shouldFailCreate) {
      throw Exception('create failed');
    }
    createdDisplayName = displayName;
    final user = UserProfile(
      id: 'created-user',
      displayName: displayName,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    selectedUser = user;
    return user;
  }
}

class _FakeUserRepository implements UserRepository {
  const _FakeUserRepository({
    this.loadedUsers = const <UserProfile>[],
    this.unloadedUsers = const <UserProfile>[],
  });

  final List<UserProfile> loadedUsers;
  final List<UserProfile> unloadedUsers;

  @override
  Future<List<UserProfile>> listLoadedUsers() async => loadedUsers;

  @override
  Future<List<UserProfile>> listUnloadedUsers() async => unloadedUsers;

  @override
  Future<List<UserProfile>> listUsers() async {
    return <UserProfile>[...loadedUsers, ...unloadedUsers];
  }

  @override
  Future<void> saveUser(UserProfile user) async {}
}

class _FakeSyncService implements SyncService {
  _FakeSyncService({this.shouldFailSyncUser = false});

  final bool shouldFailSyncUser;
  UserProfile? syncedUser;

  @override
  Future<SyncResult> syncLoadedUsers() async {
    return const SyncResult(
      status: SyncStatus.noLoadedUsers,
      refreshedUserCount: 0,
      refreshedSessionCount: 0,
    );
  }

  @override
  Future<SyncResult> syncUser(UserProfile user) async {
    syncedUser = user;
    if (shouldFailSyncUser) {
      throw Exception('sync failed');
    }
    return SyncResult(
      status: SyncStatus.refreshed,
      refreshedUserCount: 1,
      refreshedSessionCount: 0,
    );
  }
}

UserProfile _loadedUserProfile(String id) {
  return UserProfile(
    id: id,
    displayName: id,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    lastActivityAt: DateTime.utc(2026),
  );
}
