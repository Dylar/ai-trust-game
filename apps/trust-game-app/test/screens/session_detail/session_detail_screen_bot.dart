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

  void expectRequestVisible(String requestId) {
    expect(isVisible(SessionDetailKeys.requestCard(requestId)), isTrue);
  }

  void expectEmptyAnalysisVisible() {
    expect(isVisible(SessionDetailKeys.emptyAnalysisState), isTrue);
    expect(
      find.text('No analysis is available for this session yet.'),
      findsOneWidget,
    );
    expect(isVisible(SessionDetailKeys.errorState), isFalse);
    expect(find.text('The analysis could not be loaded yet.'), findsNothing);
    expect(find.text('HTTP status: 404'), findsNothing);
  }

  void expectRefreshVisible() {
    expect(isVisible(SessionDetailKeys.refreshIndicator), isTrue);
  }

  void expectRefreshHidden() {
    expect(isVisible(SessionDetailKeys.refreshIndicator), isFalse);
  }
}
