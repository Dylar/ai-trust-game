import 'package:app/core/logging/app_logger.dart';

import '../../testing/app_process.dart';
import '../../testing/test_dependencies.dart';
import 'login_fakes.dart';
import 'login_screen_bot.dart';

class LoginProcess {
  LoginProcess({
    required this.appLogger,
    required this.appProcess,
    required this.authService,
    required this.screenBot,
    required this.syncService,
    required this.userRepository,
  });

  final AppLogger appLogger;
  final AppProcess appProcess;
  final FakeLoginAuthService authService;
  final LoginScreenBot screenBot;
  final FakeLoginSyncService syncService;
  final FakeLoginUserRepository userRepository;

  Future<void> startLoginScreen() async {
    await appProcess.startLogin(
      dependencies: buildTestDependencies(
        appLogger: appLogger,
        authService: authService,
        syncService: syncService,
        userRepository: userRepository,
      ),
    );
  }

  Future<void> waitUntilLoaded() async {
    await screenBot.tester.pumpAndSettle();
  }

  Future<void> selectUser(String userId) async {
    await screenBot.selectUser(userId);
    await screenBot.tester.pumpAndSettle();
  }

  Future<void> createUser(String displayName) async {
    await screenBot.enterDisplayName(displayName);
    await screenBot.tapCreateUser();
    await screenBot.tester.pumpAndSettle();
  }

  Future<void> createUserWithoutDisplayName() async {
    await screenBot.tapCreateUser();
    await screenBot.tester.pumpAndSettle();
  }

  void expectAvailableUsersShown({
    required String loadedUserId,
    required String unloadedUserId,
  }) {
    screenBot.expectLoadedUsersVisible();
    screenBot.expectUnloadedUsersVisible();
    screenBot.expectUserVisible(loadedUserId);
    screenBot.expectUserVisible(unloadedUserId);
  }
}
