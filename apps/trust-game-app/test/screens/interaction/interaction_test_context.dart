import 'package:flutter_test/flutter_test.dart';

import '../../testing/app_bot.dart';
import '../../testing/app_process.dart';
import '../interaction/interaction_screen_bot.dart';
import 'interaction_process.dart';

class InteractionTestContext {
  InteractionTestContext(this.tester)
    : appBot = AppBot(tester),
      screenBot = InteractionScreenBot(tester) {
    appProcess = AppProcess(appBot);
    process = InteractionProcess(appProcess: appProcess, screenBot: screenBot);
  }

  final WidgetTester tester;
  final AppBot appBot;
  late final AppProcess appProcess;
  final InteractionScreenBot screenBot;
  late final InteractionProcess process;
}
