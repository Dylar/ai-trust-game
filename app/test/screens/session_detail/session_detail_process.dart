import 'session_detail_screen_bot.dart';

class SessionDetailProcess {
  const SessionDetailProcess(this.screenBot);

  final SessionDetailScreenBot screenBot;

  Future<void> expectAnalysisLoaded({
    required String sessionId,
    required String classification,
  }) async {
    screenBot.expectScreenVisible();
    screenBot.expectAnalysisVisible();
    screenBot.expectSessionIdShown(sessionId);
    screenBot.expectClassificationShown(classification);
  }
}
