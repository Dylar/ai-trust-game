import '../../testing/base_screen_bot.dart';
import '../session_start/session_start_process.dart';
import 'home_screen_bot.dart';

class HomeProcess {
  HomeProcess(this.baseBot, this.screenBot, this.sessionStartProcess);

  final BaseScreenBot baseBot;
  final HomeScreenBot screenBot;
  final SessionStartProcess sessionStartProcess;

  Future<void> openSessionStart() async {
    await screenBot.tapStartSession();
    await baseBot.pump(const Duration(milliseconds: 1));
  }

  Future<void> createAdminHardSessionFromHome() async {
    await openSessionStart();
    await sessionStartProcess.prepareAdminHardSession();
  }
}
