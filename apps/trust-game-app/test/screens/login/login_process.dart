import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/data/session/session_repository.dart';

import '../../testing/app_process.dart';
import '../../testing/test_dependencies.dart';
import 'login_fakes.dart';
import 'login_screen_bot.dart';

class LoginProcess {
  LoginProcess({
    required this.appLogger,
    required this.appProcess,
    required this.authApi,
    required this.interactionApi,
    required this.screenBot,
    required this.selectedUser,
    required this.sessionApi,
    required this.sessionRepository,
    required this.userRepository,
  });

  final AppLogger appLogger;
  final AppProcess appProcess;
  final FakeLoginAuthApi authApi;
  final FakeLoginInteractionApi interactionApi;
  final LoginScreenBot screenBot;
  final SelectedUserController selectedUser;
  final FakeLoginSessionApi sessionApi;
  final SessionRepository sessionRepository;
  final FakeLoginUserRepository userRepository;

  Future<void> startLoginScreen() async {
    await appProcess.startLogin(
      dependencies: buildTestDependencies(
        appLogger: appLogger,
        authApi: authApi,
        interactionApi: interactionApi,
        selectedUser: selectedUser,
        sessionApi: sessionApi,
        sessionRepository: sessionRepository,
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
