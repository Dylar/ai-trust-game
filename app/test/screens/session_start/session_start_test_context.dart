import 'package:flutter_test/flutter_test.dart';

import '../../testing/app_bot.dart';
import '../../testing/base_screen_bot.dart';
import '../session_start/session_start_process.dart';
import '../session_start/session_start_screen_bot.dart';

class SessionStartTestContext {
  SessionStartTestContext(this.tester)
    : appBot = AppBot(tester),
      baseBot = BaseScreenBot(tester),
      screenBot = SessionStartScreenBot(tester);

  final WidgetTester tester;
  final AppBot appBot;
  final BaseScreenBot baseBot;
  final SessionStartScreenBot screenBot;
  late final SessionStartProcess process = SessionStartProcess(
    baseBot,
    screenBot,
  );
}
