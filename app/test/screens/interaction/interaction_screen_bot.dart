import 'package:app/screens/interaction/interaction_keys.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/base_screen_bot.dart';

class InteractionScreenBot extends BaseScreenBot {
  InteractionScreenBot(super.tester);

  void expectScreenVisible() {
    expect(isVisible(InteractionKeys.screen), isTrue);
    expect(isVisible(InteractionKeys.title), isTrue);
  }

  void expectSessionDetailsVisible() {
    expect(isVisible(InteractionKeys.sessionDetailsSection), isTrue);
    expect(isVisible(InteractionKeys.sessionIdItem), isTrue);
    expect(isVisible(InteractionKeys.roleItem), isTrue);
    expect(isVisible(InteractionKeys.modeItem), isTrue);
    expect(isVisible(InteractionKeys.previewItem), isTrue);
  }

  void expectNotFoundVisible() {
    expect(isVisible(InteractionKeys.notFoundState), isTrue);
  }

  void expectSessionIdShown(String sessionId) {
    expect(find.text(sessionId), findsOneWidget);
  }
}
