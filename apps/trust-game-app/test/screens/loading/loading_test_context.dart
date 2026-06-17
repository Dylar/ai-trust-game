import 'package:app/core/logging/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/app_bot.dart';
import '../../testing/app_process.dart';
import 'loading_fakes.dart';
import 'loading_process.dart';
import 'loading_screen_bot.dart';

class LoadingTestContext {
  LoadingTestContext(
    this.tester, {
    AppLogger? appLogger,
    FakeLoadingAuthService? authService,
    FakeLoadingSyncService? syncService,
  }) : appBot = AppBot(tester),
       screenBot = LoadingScreenBot(tester),
       appLogger = appLogger ?? const AppLogger(sinks: <AppLogSink>[]),
       authService = authService ?? const FakeLoadingAuthService(),
       syncService = syncService ?? FakeLoadingSyncService() {
    appProcess = AppProcess(appBot);
    process = LoadingProcess(
      appLogger: this.appLogger,
      appProcess: appProcess,
      authService: this.authService,
      screenBot: screenBot,
      syncService: this.syncService,
    );
  }

  final WidgetTester tester;
  final AppBot appBot;
  late final AppProcess appProcess;
  final LoadingScreenBot screenBot;
  final AppLogger appLogger;
  final FakeLoadingAuthService authService;
  final FakeLoadingSyncService syncService;
  late final LoadingProcess process;
}
