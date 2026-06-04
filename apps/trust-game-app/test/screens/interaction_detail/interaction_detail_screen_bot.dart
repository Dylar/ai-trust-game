import 'package:app/screens/interaction_detail/interaction_detail_keys.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/base_screen_bot.dart';

class InteractionDetailScreenBot extends BaseScreenBot {
  InteractionDetailScreenBot(super.tester);

  void expectScreenVisible() {
    expect(isVisible(InteractionDetailKeys.screen), isTrue);
  }

  void expectAnalysisVisible() {
    expect(isVisible(InteractionDetailKeys.analysisSection), isTrue);
  }

  void expectRequestIdShown(String requestId) {
    expect(find.text(requestId), findsOneWidget);
  }

  void expectClassificationShown(String classification) {
    expect(find.text(classification), findsOneWidget);
  }
}
