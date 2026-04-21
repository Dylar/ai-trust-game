import 'package:app/screens/home/home_keys.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/base_screen_bot.dart';

class HomeScreenBot extends BaseScreenBot {
  HomeScreenBot(super.tester);

  void expectScreenVisible() {
    expect(isVisible(HomeKeys.screen), isTrue);
    expect(isVisible(HomeKeys.title), isTrue);
  }

  void expectStartSessionVisible() {
    expect(isVisible(HomeKeys.startSessionButton), isTrue);
  }

  void expectRecentSessionsVisible() {
    expect(isVisible(HomeKeys.recentSessionsSection), isTrue);
    expect(isVisible(HomeKeys.sessionGuestEasy), isTrue);
    expect(isVisible(HomeKeys.sessionEmployeeMedium), isTrue);
    expect(isVisible(HomeKeys.sessionAdminHard), isTrue);
  }
}
