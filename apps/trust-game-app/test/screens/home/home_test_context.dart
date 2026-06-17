import 'package:flutter_test/flutter_test.dart';

import '../../testing/app_bot.dart';
import '../../testing/app_process.dart';
import '../interaction/interaction_screen_bot.dart';
import '../session_start/session_start_process.dart';
import '../session_start/session_start_screen_bot.dart';
import 'home_process.dart';
import 'home_screen_bot.dart';

class HomeTestContext {
  HomeTestContext(this.tester)
    : appBot = AppBot(tester),
      screenBot = HomeScreenBot(tester),
      interactionScreenBot = InteractionScreenBot(tester),
      sessionStartBot = SessionStartScreenBot(tester) {
    appProcess = AppProcess(appBot);
    sessionStartProcess = SessionStartProcess(
      appProcess: appProcess,
      screenBot: sessionStartBot,
    );
    process = HomeProcess(
      appProcess: appProcess,
      screenBot: screenBot,
      sessionStartProcess: sessionStartProcess,
      tester: tester,
    );
  }

  final WidgetTester tester;
  final AppBot appBot;
  late final AppProcess appProcess;
  final HomeScreenBot screenBot;
  final InteractionScreenBot interactionScreenBot;
  final SessionStartScreenBot sessionStartBot;
  late final SessionStartProcess sessionStartProcess;
  late final HomeProcess process;
}
