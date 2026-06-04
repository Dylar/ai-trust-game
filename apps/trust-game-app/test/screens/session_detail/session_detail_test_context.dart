import 'package:flutter_test/flutter_test.dart';

import '../../testing/app_bot.dart';
import '../../testing/base_screen_bot.dart';
import 'session_detail_process.dart';
import 'session_detail_screen_bot.dart';

class SessionDetailTestContext {
  SessionDetailTestContext(this.tester)
    : appBot = AppBot(tester),
      baseBot = BaseScreenBot(tester),
      screenBot = SessionDetailScreenBot(tester) {
    process = SessionDetailProcess(screenBot);
  }

  final WidgetTester tester;
  final AppBot appBot;
  final BaseScreenBot baseBot;
  final SessionDetailScreenBot screenBot;
  late final SessionDetailProcess process;
}
