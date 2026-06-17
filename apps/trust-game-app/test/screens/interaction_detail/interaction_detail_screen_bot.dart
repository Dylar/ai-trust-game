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

  void expectEmptyAnalysisVisible() {
    expect(isVisible(InteractionDetailKeys.emptyAnalysisState), isTrue);
    expect(
      find.text('No analysis is available for this interaction yet.'),
      findsOneWidget,
    );
    expect(isVisible(InteractionDetailKeys.errorState), isFalse);
    expect(find.text('The analysis could not be loaded yet.'), findsNothing);
    expect(find.text('HTTP status: 404'), findsNothing);
  }

  void expectRefreshVisible() {
    expect(isVisible(InteractionDetailKeys.refreshIndicator), isTrue);
  }

  void expectRefreshHidden() {
    expect(isVisible(InteractionDetailKeys.refreshIndicator), isFalse);
  }
}
