import '../../testing/base_screen_bot.dart';
import 'session_start_screen_bot.dart';

class SessionStartProcess {
  SessionStartProcess(this.baseBot, this.screenBot);

  final BaseScreenBot baseBot;
  final SessionStartScreenBot screenBot;

  Future<void> waitUntilPreparationFinished() async {
    await baseBot.pump(const Duration(milliseconds: 300));
    await baseBot.pump(const Duration(milliseconds: 1));
  }

  Future<void> prepareAdminHardSession() async {
    await screenBot.selectAdminRole();
    await screenBot.selectHardMode();
    await screenBot.tapPrepareSession();
    await waitUntilPreparationFinished();
  }
}
