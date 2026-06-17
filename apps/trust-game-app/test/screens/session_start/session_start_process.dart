import '../../testing/app_process.dart';
import '../../testing/test_dependencies.dart';
import '../session_start/session_start_fakes.dart';
import '../session_start/session_start_screen_bot.dart';

class SessionStartProcess {
  SessionStartProcess({required this.appProcess, required this.screenBot});

  final AppProcess appProcess;
  final SessionStartScreenBot screenBot;

  Future<void> startSessionStartScreen() async {
    await appProcess.startSessionStart();
  }

  Future<void> startWithSessionStartFailure({required int statusCode}) async {
    await appProcess.startSessionStart(
      dependencies: buildTestDependencies(
        httpClient: sessionStartFailureClient(statusCode: statusCode),
      ),
    );
  }

  Future<void> startWithOfflineSessionStart() async {
    await appProcess.startSessionStart(
      dependencies: buildTestDependencies(
        httpClient: offlineSessionStartClient(),
      ),
    );
  }

  Future<void> waitUntilPreparationFinished() async {
    await screenBot.pump(const Duration(milliseconds: 300));
    await screenBot.pump(const Duration(milliseconds: 1));
  }

  Future<void> prepareAdminHardSession() async {
    await screenBot.selectAdminRole();
    await screenBot.selectHardMode();
    await screenBot.tapPrepareSession();
    await waitUntilPreparationFinished();
  }

  Future<void> prepareSessionExpectingDialog() async {
    await screenBot.tapPrepareSession();
    await screenBot.pumpAndSettle();
  }
}
