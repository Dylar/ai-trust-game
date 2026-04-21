import 'interaction_detail_screen_bot.dart';

class InteractionDetailProcess {
  const InteractionDetailProcess(this.screenBot);

  final InteractionDetailScreenBot screenBot;

  Future<void> expectAnalysisLoaded({
    required String requestId,
    required String classification,
  }) async {
    screenBot.expectScreenVisible();
    screenBot.expectAnalysisVisible();
    screenBot.expectRequestIdShown(requestId);
    screenBot.expectClassificationShown(classification);
  }
}
