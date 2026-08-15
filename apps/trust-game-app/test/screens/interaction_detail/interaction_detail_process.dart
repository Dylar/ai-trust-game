import 'package:app/data/analysis/analysis_repository.dart';
import 'package:app/models/analysis_models.dart';

import '../../testing/app_process.dart';
import '../../testing/mocks/analysis_api_mocks.dart';
import '../../testing/test_dependencies.dart';
import 'interaction_detail_fakes.dart';
import 'interaction_detail_screen_bot.dart';

class InteractionDetailProcess {
  const InteractionDetailProcess({
    required this.appProcess,
    required this.screenBot,
  });

  final AppProcess appProcess;
  final InteractionDetailScreenBot screenBot;

  Future<void> startInteractionDetail(String requestId) async {
    await appProcess.startInteractionDetail(requestId: requestId);
  }

  Future<void> startWithMissingAnalysis(String requestId) async {
    await appProcess.startInteractionDetail(
      requestId: requestId,
      dependencies: buildTestDependencies(
        httpClient: missingRequestAnalysisClient(),
      ),
    );
  }

  Future<PendingRefreshRequestAnalysisApi> startWithPendingRefresh({
    required String requestId,
  }) async {
    final analysisApi = PendingRefreshRequestAnalysisApi(requestId: requestId);
    await appProcess.startInteractionDetail(
      requestId: requestId,
      dependencies: buildTestDependencies(
        analysisApi: analysisApi,
        analysisRepository: InMemoryAnalysisRepository(
          initialRequestAnalyses: <String, RequestAnalysis>{
            requestId: testRequestAnalysis(
              requestId: requestId,
              classification: 'cached',
            ),
          },
        ),
      ),
    );
    return analysisApi;
  }

  Future<void> waitUntilLoaded() async {
    await screenBot.pump(const Duration(milliseconds: 1));
  }

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
