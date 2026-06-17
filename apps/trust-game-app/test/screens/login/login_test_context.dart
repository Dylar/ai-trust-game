import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/app_bot.dart';
import '../../testing/app_process.dart';
import 'login_fakes.dart';
import 'login_process.dart';
import 'login_screen_bot.dart';

class LoginTestContext {
  LoginTestContext(
    this.tester, {
    FakeLoginAuthService? authService,
    AppLogger? appLogger,
    FakeLoginSyncService? syncService,
    List<UserProfile> loadedUsers = const <UserProfile>[],
    List<UserProfile> unloadedUsers = const <UserProfile>[],
  }) : appBot = AppBot(tester),
       screenBot = LoginScreenBot(tester),
       authService = authService ?? FakeLoginAuthService(),
       syncService = syncService ?? FakeLoginSyncService(),
       userRepository = FakeLoginUserRepository(
         loadedUsers: loadedUsers,
         unloadedUsers: unloadedUsers,
       ),
       appLogger = appLogger ?? const AppLogger(sinks: <AppLogSink>[]) {
    appProcess = AppProcess(appBot);
    process = LoginProcess(
      appLogger: this.appLogger,
      appProcess: appProcess,
      authService: this.authService,
      screenBot: screenBot,
      syncService: this.syncService,
      userRepository: userRepository,
    );
  }

  final WidgetTester tester;
  final AppBot appBot;
  late final AppProcess appProcess;
  final LoginScreenBot screenBot;
  final FakeLoginAuthService authService;
  final FakeLoginSyncService syncService;
  final FakeLoginUserRepository userRepository;
  final AppLogger appLogger;
  late final LoginProcess process;
}
