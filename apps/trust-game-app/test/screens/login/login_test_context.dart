import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/app_bot.dart';
import '../../testing/app_process.dart';
import 'login_fakes.dart';
import 'login_process.dart';
import 'login_screen_bot.dart';

class LoginTestContext {
  LoginTestContext(
    this.tester, {
    FakeLoginAuthApi? authApi,
    AppLogger? appLogger,
    FakeLoginInteractionApi? interactionApi,
    SelectedUserController? selectedUser,
    FakeLoginSessionApi? sessionApi,
    SessionRepository? sessionRepository,
    List<UserProfile> loadedUsers = const <UserProfile>[],
    List<UserProfile> unloadedUsers = const <UserProfile>[],
  }) : appBot = AppBot(tester),
       screenBot = LoginScreenBot(tester),
       authApi = authApi ?? FakeLoginAuthApi(),
       interactionApi = interactionApi ?? const FakeLoginInteractionApi(),
       selectedUser = selectedUser ?? SelectedUserController(),
       sessionApi = sessionApi ?? FakeLoginSessionApi(),
       sessionRepository = sessionRepository ?? InMemorySessionRepository(),
       userRepository = FakeLoginUserRepository(
         loadedUsers: loadedUsers,
         unloadedUsers: unloadedUsers,
       ),
       appLogger = appLogger ?? const AppLogger(sinks: <AppLogSink>[]) {
    appProcess = AppProcess(appBot);
    process = LoginProcess(
      appLogger: this.appLogger,
      appProcess: appProcess,
      authApi: this.authApi,
      interactionApi: this.interactionApi,
      screenBot: screenBot,
      selectedUser: this.selectedUser,
      sessionApi: this.sessionApi,
      sessionRepository: this.sessionRepository,
      userRepository: userRepository,
    );
  }

  final WidgetTester tester;
  final AppBot appBot;
  late final AppProcess appProcess;
  final LoginScreenBot screenBot;
  final FakeLoginAuthApi authApi;
  final FakeLoginInteractionApi interactionApi;
  final SelectedUserController selectedUser;
  final FakeLoginSessionApi sessionApi;
  final SessionRepository sessionRepository;
  final FakeLoginUserRepository userRepository;
  final AppLogger appLogger;
  late final LoginProcess process;
}
