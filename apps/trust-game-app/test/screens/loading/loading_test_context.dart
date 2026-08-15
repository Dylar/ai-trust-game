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
    FakeLoadingAuthApi? authApi,
  }) : appBot = AppBot(tester),
       screenBot = LoadingScreenBot(tester),
       appLogger = appLogger ?? const AppLogger(sinks: <AppLogSink>[]),
       authApi = authApi ?? const FakeLoadingAuthApi() {
    appProcess = AppProcess(appBot);
    process = LoadingProcess(
      appLogger: this.appLogger,
      appProcess: appProcess,
      authApi: this.authApi,
      screenBot: screenBot,
    );
  }

  final WidgetTester tester;
  final AppBot appBot;
  late final AppProcess appProcess;
  final LoadingScreenBot screenBot;
  final AppLogger appLogger;
  final FakeLoadingAuthApi authApi;
  late final LoadingProcess process;
}
