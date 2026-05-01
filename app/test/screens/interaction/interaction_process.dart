import '../../testing/base_screen_bot.dart';
import '../interaction/interaction_screen_bot.dart';

class InteractionProcess {
  InteractionProcess(this.baseBot, this.screenBot);

  final BaseScreenBot baseBot;
  final InteractionScreenBot screenBot;

  Future<void> waitUntilSessionLoaded() async {
    await baseBot.pump(const Duration(milliseconds: 1));
  }

  Future<void> expectSessionDetailsLoaded(String sessionId) async {
    await waitUntilSessionLoaded();
    screenBot.expectScreenVisible();
    screenBot.expectSessionDetailsVisible();
    screenBot.expectSessionIdShown(sessionId);
  }

  Future<void> sendMessage(String message) async {
    await screenBot.enterMessage(message);
    screenBot.expectSendButtonEnabled();
    await screenBot.tapSendMessage();
    await baseBot.pump(const Duration(milliseconds: 1));
  }

  Future<void> expectInteractionCreated(String message) async {
    await screenBot.expectInteractionMessageShown(message);
    await screenBot.expectPlaceholderAnswerShown(message);
  }

  Future<void> expectSessionNotFound() async {
    await waitUntilSessionLoaded();
    screenBot.expectScreenVisible();
    screenBot.expectNotFoundVisible();
  }
}
