import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:app/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/mocks/recording_app_log_sink.dart';
import 'login_fakes.dart';
import 'login_test_context.dart';

void main() {
  testWidgets(
    'GIVEN loaded and unloaded users WHEN login screen opens THEN shows both user lists',
    (tester) async {
      final context = LoginTestContext(
        tester,
        loadedUsers: <UserProfile>[loadedLoginUserProfile('loaded-user')],
        unloadedUsers: <UserProfile>[unloadedLoginUserProfile('unloaded-user')],
      );

      // Given
      await context.process.startLoginScreen();

      // When
      await context.process.waitUntilLoaded();

      // Then
      context.process.expectAvailableUsersShown(
        loadedUserId: 'loaded-user',
        unloadedUserId: 'unloaded-user',
      );
    },
  );

  testWidgets('GIVEN existing user WHEN selecting user THEN logs in', (
    tester,
  ) async {
    final user = loadedLoginUserProfile('loaded-user');
    final context = LoginTestContext(tester, loadedUsers: <UserProfile>[user]);

    // Given
    await context.process.startLoginScreen();
    await context.process.waitUntilLoaded();

    // When
    await context.process.selectUser('loaded-user');

    // Then
    expect(context.authService.selectedUser, user);
    context.screenBot.expectHomeVisible();
  });

  testWidgets(
    'GIVEN loaded user and failed sync WHEN selecting user THEN logs in',
    (tester) async {
      final user = loadedLoginUserProfile('loaded-user');
      final syncService = FakeLoginSyncService(
        syncUserStatus: SyncStatus.failed,
      );
      final context = LoginTestContext(
        tester,
        syncService: syncService,
        loadedUsers: <UserProfile>[user],
      );

      // Given
      await context.process.startLoginScreen();
      await context.process.waitUntilLoaded();

      // When
      await context.process.selectUser('loaded-user');

      // Then
      expect(context.authService.selectedUser, user);
      expect(syncService.syncedUser, user);
      context.screenBot.expectHomeVisible();
    },
  );

  testWidgets(
    'GIVEN unloaded user and failed sync WHEN selecting user THEN stays on login',
    (tester) async {
      final user = unloadedLoginUserProfile('unloaded-user');
      final syncService = FakeLoginSyncService(
        syncUserStatus: SyncStatus.failed,
      );
      final context = LoginTestContext(
        tester,
        syncService: syncService,
        unloadedUsers: <UserProfile>[user],
      );

      // Given
      await context.process.startLoginScreen();
      await context.process.waitUntilLoaded();

      // When
      await context.process.selectUser('unloaded-user');

      // Then
      expect(context.authService.selectedUser, isNull);
      expect(syncService.syncedUser, user);
      context.screenBot.expectSelectedUserLoadErrorVisible();
      context.screenBot.expectScreenVisible();
    },
  );

  testWidgets(
    'GIVEN sync exception WHEN selecting user THEN logs and shows error dialog',
    (tester) async {
      final user = unloadedLoginUserProfile('unloaded-user');
      final sink = RecordingAppLogSink();
      final syncService = FakeLoginSyncService(shouldFailSyncUser: true);
      final context = LoginTestContext(
        tester,
        appLogger: AppLogger(sinks: <AppLogSink>[sink]),
        syncService: syncService,
        unloadedUsers: <UserProfile>[user],
      );

      // Given
      await context.process.startLoginScreen();
      await context.process.waitUntilLoaded();

      // When
      await context.process.selectUser('unloaded-user');

      // Then
      expect(context.authService.selectedUser, isNull);
      expect(syncService.syncedUser, user);
      expect(sink.events, hasLength(1));
      expect(sink.events.single.category, 'login');
      expect(sink.events.single.message, 'Login user selection failed');
      expect(sink.events.single.attributes['userId'], 'unloaded-user');
      context.screenBot.expectSelectedUserLoadErrorVisible();
      context.screenBot.expectScreenVisible();
    },
  );

  testWidgets(
    'GIVEN display name WHEN creating user THEN creates user and logs in',
    (tester) async {
      final context = LoginTestContext(tester);

      // Given
      await context.process.startLoginScreen();
      await context.process.waitUntilLoaded();

      // When
      await context.process.createUser('Alice');

      // Then
      expect(context.authService.createdDisplayName, 'Alice');
      context.screenBot.expectHomeVisible();
    },
  );

  testWidgets(
    'GIVEN empty display name WHEN creating user THEN stays on login screen',
    (tester) async {
      final context = LoginTestContext(tester);

      // Given
      await context.process.startLoginScreen();
      await context.process.waitUntilLoaded();

      // When
      await context.process.createUserWithoutDisplayName();

      // Then
      context.screenBot.expectEmptyDisplayNameErrorVisible();
      expect(context.authService.createdDisplayName, isNull);
      context.screenBot.expectScreenVisible();
    },
  );

  testWidgets(
    'GIVEN unreachable backend WHEN creating user THEN shows error dialog',
    (tester) async {
      final sink = RecordingAppLogSink();
      final context = LoginTestContext(
        tester,
        appLogger: AppLogger(sinks: <AppLogSink>[sink]),
        authService: FakeLoginAuthService(shouldFailCreate: true),
      );

      // Given
      await context.process.startLoginScreen();
      await context.process.waitUntilLoaded();

      // When
      await context.process.createUser('Alice');

      // Then
      context.screenBot.expectCreateUserErrorVisible();
      expect(sink.events, hasLength(1));
      expect(sink.events.single.category, 'login');
      expect(sink.events.single.message, 'Login user creation failed');
      expect(sink.events.single.attributes['displayNameLength'], 5);
      expect(context.authService.createdDisplayName, isNull);
      context.screenBot.expectScreenVisible();
    },
  );
}
