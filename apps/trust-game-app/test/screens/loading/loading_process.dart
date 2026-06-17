import 'package:app/core/logging/app_logger.dart';

import '../../testing/app_process.dart';
import '../../testing/test_dependencies.dart';
import 'loading_fakes.dart';
import 'loading_screen_bot.dart';

class LoadingProcess {
  LoadingProcess({
    required this.appLogger,
    required this.appProcess,
    required this.authService,
    required this.screenBot,
    required this.syncService,
  });

  final AppLogger appLogger;
  final AppProcess appProcess;
  final FakeLoadingAuthService authService;
  final LoadingScreenBot screenBot;
  final FakeLoadingSyncService syncService;

  Future<void> startLoadingScreen() async {
    await appProcess.startLoading(
      dependencies: buildTestDependencies(
        appLogger: appLogger,
        authService: authService,
        syncService: syncService,
      ),
    );
  }

  Future<void> waitJustBeforeMinimumDisplayDuration() async {
    await screenBot.tester.pump();
    await screenBot.pump(const Duration(milliseconds: 999));
  }

  Future<void> finishMinimumDisplayDuration() async {
    await screenBot.pump(const Duration(milliseconds: 1));
    await screenBot.tester.pumpAndSettle();
  }

  Future<void> waitUntilRetryVisible() async {
    await screenBot.tester.pump();
    await screenBot.pump(const Duration(seconds: 1));
  }
}
