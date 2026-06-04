import 'package:flutter_test/flutter_test.dart';

import '../interaction/interaction_screen_bot.dart';
import '../session_start/session_start_process.dart';
import '../session_start/session_start_screen_bot.dart';
import '../../testing/app_bot.dart';
import '../../testing/base_screen_bot.dart';
import 'home_process.dart';
import 'home_screen_bot.dart';

class HomeTestContext {
  HomeTestContext(this.tester)
    : appBot = AppBot(tester),
      baseBot = BaseScreenBot(tester),
      screenBot = HomeScreenBot(tester),
      interactionScreenBot = InteractionScreenBot(tester),
      sessionStartBot = SessionStartScreenBot(tester);

  final WidgetTester tester;
  final AppBot appBot;
  final BaseScreenBot baseBot;
  final HomeScreenBot screenBot;
  final InteractionScreenBot interactionScreenBot;
  final SessionStartScreenBot sessionStartBot;
  late final SessionStartProcess sessionStartProcess = SessionStartProcess(
    baseBot,
    sessionStartBot,
  );
  late final HomeProcess process = HomeProcess(
    baseBot,
    screenBot,
    sessionStartProcess,
  );
}
