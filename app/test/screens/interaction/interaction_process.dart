import 'interaction_screen_bot.dart';

class InteractionProcess {
  InteractionProcess(this.screenBot);

  final InteractionScreenBot screenBot;

  void expectSessionDetailsLoaded(String sessionId) {
    screenBot.expectScreenVisible();
    screenBot.expectSessionDetailsVisible();
    screenBot.expectSessionIdShown(sessionId);
  }
}
