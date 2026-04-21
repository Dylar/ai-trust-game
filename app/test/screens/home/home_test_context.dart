import 'package:flutter_test/flutter_test.dart';

import '../../testing/app_bot.dart';
import '../../testing/base_screen_bot.dart';
import 'home_screen_bot.dart';

class HomeTestContext {
  HomeTestContext(this.tester)
    : appBot = AppBot(tester),
      baseBot = BaseScreenBot(tester),
      screenBot = HomeScreenBot(tester);

  final WidgetTester tester;
  final AppBot appBot;
  final BaseScreenBot baseBot;
  final HomeScreenBot screenBot;
}
