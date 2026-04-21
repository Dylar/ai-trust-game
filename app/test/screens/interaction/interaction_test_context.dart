import 'package:flutter_test/flutter_test.dart';

import '../../testing/app_bot.dart';
import '../../testing/base_screen_bot.dart';
import 'interaction_process.dart';
import 'interaction_screen_bot.dart';

class InteractionTestContext {
  InteractionTestContext(this.tester)
    : appBot = AppBot(tester),
      baseBot = BaseScreenBot(tester),
      screenBot = InteractionScreenBot(tester);

  final WidgetTester tester;
  final AppBot appBot;
  final BaseScreenBot baseBot;
  final InteractionScreenBot screenBot;
  late final InteractionProcess process = InteractionProcess(screenBot);
}
