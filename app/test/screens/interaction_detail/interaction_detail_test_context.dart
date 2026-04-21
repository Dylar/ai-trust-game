import 'package:flutter_test/flutter_test.dart';

import '../../testing/app_bot.dart';
import '../../testing/base_screen_bot.dart';
import 'interaction_detail_process.dart';
import 'interaction_detail_screen_bot.dart';

class InteractionDetailTestContext {
  InteractionDetailTestContext(this.tester)
    : appBot = AppBot(tester),
      baseBot = BaseScreenBot(tester),
      screenBot = InteractionDetailScreenBot(tester) {
    process = InteractionDetailProcess(screenBot);
  }

  final WidgetTester tester;
  final AppBot appBot;
  final BaseScreenBot baseBot;
  final InteractionDetailScreenBot screenBot;
  late final InteractionDetailProcess process;
}
