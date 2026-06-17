import 'package:flutter_test/flutter_test.dart';

import '../../testing/app_bot.dart';
import '../../testing/app_process.dart';
import 'interaction_detail_process.dart';
import 'interaction_detail_screen_bot.dart';

class InteractionDetailTestContext {
  InteractionDetailTestContext(this.tester)
    : appBot = AppBot(tester),
      screenBot = InteractionDetailScreenBot(tester) {
    appProcess = AppProcess(appBot);
    process = InteractionDetailProcess(
      appProcess: appProcess,
      screenBot: screenBot,
    );
  }

  final WidgetTester tester;
  final AppBot appBot;
  late final AppProcess appProcess;
  final InteractionDetailScreenBot screenBot;
  late final InteractionDetailProcess process;
}
