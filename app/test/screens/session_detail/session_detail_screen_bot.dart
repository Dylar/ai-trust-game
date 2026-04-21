import 'package:app/screens/session_detail/session_detail_keys.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/base_screen_bot.dart';

class SessionDetailScreenBot extends BaseScreenBot {
  SessionDetailScreenBot(super.tester);

  void expectScreenVisible() {
    expect(isVisible(SessionDetailKeys.screen), isTrue);
  }

  void expectAnalysisVisible() {
    expect(isVisible(SessionDetailKeys.analysisSection), isTrue);
  }

  void expectSessionIdShown(String sessionId) {
    expect(find.text(sessionId), findsOneWidget);
  }

  void expectClassificationShown(String classification) {
    expect(find.text(classification), findsOneWidget);
  }
}
