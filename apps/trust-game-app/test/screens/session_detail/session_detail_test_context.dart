import 'package:flutter_test/flutter_test.dart';

import '../../testing/app_bot.dart';
import '../../testing/app_process.dart';
import 'session_detail_process.dart';
import 'session_detail_screen_bot.dart';

class SessionDetailTestContext {
  SessionDetailTestContext(this.tester)
    : appBot = AppBot(tester),
      screenBot = SessionDetailScreenBot(tester) {
    appProcess = AppProcess(appBot);
    process = SessionDetailProcess(
      appProcess: appProcess,
      screenBot: screenBot,
    );
  }

  final WidgetTester tester;
  final AppBot appBot;
  late final AppProcess appProcess;
  final SessionDetailScreenBot screenBot;
  late final SessionDetailProcess process;
}
