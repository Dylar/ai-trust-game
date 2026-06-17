import 'package:flutter_test/flutter_test.dart';

import '../../testing/app_bot.dart';
import '../../testing/app_process.dart';
import '../session_start/session_start_process.dart';
import '../session_start/session_start_screen_bot.dart';

class SessionStartTestContext {
  SessionStartTestContext(this.tester)
    : appBot = AppBot(tester),
      screenBot = SessionStartScreenBot(tester) {
    appProcess = AppProcess(appBot);
    process = SessionStartProcess(appProcess: appProcess, screenBot: screenBot);
  }

  final WidgetTester tester;
  final AppBot appBot;
  late final AppProcess appProcess;
  final SessionStartScreenBot screenBot;
  late final SessionStartProcess process;
}
