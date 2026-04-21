import 'package:app/screens/home/home_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/base_screen_bot.dart';

class HomeScreenBot extends BaseScreenBot {
  HomeScreenBot(super.tester);

  Future<void> tapStartSession() async {
    await tap(HomeKeys.startSessionButton);
  }

  void expectScreenVisible() {
    expect(isVisible(HomeKeys.screen), isTrue);
    expect(isVisible(HomeKeys.title), isTrue);
  }

  void expectStartSessionVisible() {
    expect(isVisible(HomeKeys.startSessionButton), isTrue);
  }

  void expectEmptySessionsVisible() {
    expect(isVisible(HomeKeys.recentSessionsSection), isTrue);
    expect(isVisible(HomeKeys.emptySessionsState), isTrue);
  }

  void expectRecentSessionsVisible() {
    expect(isVisible(HomeKeys.recentSessionsSection), isTrue);
    expect(isVisible(HomeKeys.emptySessionsState), isFalse);
  }

  void expectRecentSessionVisible(String sessionId) {
    expect(isVisible(HomeKeys.session(sessionId)), isTrue);
  }

  void expectRecentSessionCount(int count) {
    expect(
      find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey<String> && key.value.startsWith('home.session.');
      }),
      findsNWidgets(count),
    );
  }
}
