import '../../testing/app_process.dart';
import '../../testing/test_dependencies.dart';
import 'session_detail_fakes.dart';
import 'session_detail_screen_bot.dart';

class SessionDetailProcess {
  const SessionDetailProcess({
    required this.appProcess,
    required this.screenBot,
  });

  final AppProcess appProcess;
  final SessionDetailScreenBot screenBot;

  Future<void> startSessionDetail(String sessionId) async {
    await appProcess.startSessionDetail(sessionId: sessionId);
  }

  Future<void> startWithMissingAnalysis(String sessionId) async {
    await appProcess.startSessionDetail(
      sessionId: sessionId,
      dependencies: buildTestDependencies(
        httpClient: missingSessionAnalysisClient(),
      ),
    );
  }

  Future<PendingRefreshSessionAnalysisService> startWithPendingRefresh({
    required String sessionId,
  }) async {
    final analysisService = PendingRefreshSessionAnalysisService(
      sessionId: sessionId,
    );
    await appProcess.startSessionDetail(
      sessionId: sessionId,
      dependencies: buildTestDependencies(analysisService: analysisService),
    );
    return analysisService;
  }

  Future<void> waitUntilLoaded() async {
    await screenBot.pump(const Duration(milliseconds: 1));
  }

  Future<void> expectAnalysisLoaded({
    required String sessionId,
    required String classification,
  }) async {
    screenBot.expectScreenVisible();
    screenBot.expectAnalysisVisible();
    screenBot.expectSessionIdShown(sessionId);
    screenBot.expectClassificationShown(classification);
  }

  Future<void> expectRequestVisible(String requestId) async {
    screenBot.expectRequestVisible(requestId);
  }
}
