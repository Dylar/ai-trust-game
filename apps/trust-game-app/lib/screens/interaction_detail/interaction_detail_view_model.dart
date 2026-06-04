import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/screens/interaction_detail/interaction_detail_logger.dart';
import 'package:app/screens/interaction_detail/interaction_detail_screen_state.dart';
import 'package:app/services/analysis_service.dart';
import 'package:flutter/foundation.dart';

class InteractionDetailViewModel {
  InteractionDetailViewModel({
    required AppLogger appLogger,
    required AnalysisService analysisService,
    required String requestId,
  }) : _analysisService = analysisService,
       _logger = InteractionDetailLogger(appLogger: appLogger),
       state = ValueNotifier(
         InteractionDetailScreenState.initial(requestId: requestId),
       ) {
    loadRequestAnalysis();
  }

  final AnalysisService _analysisService;
  final InteractionDetailLogger _logger;
  final ValueNotifier<InteractionDetailScreenState> state;

  Future<void> loadRequestAnalysis() async {
    state.value = state.value.copyWith(
      status: InteractionDetailStatus.loading,
      resetError: true,
    );
    await _logger.logAnalysisLoadStarted(requestId: state.value.requestId);

    try {
      final analysis = await _analysisService.getRequestAnalysis(
        state.value.requestId,
      );
      await _logger.logAnalysisLoadSucceeded(analysis: analysis);
      state.value = state.value.copyWith(
        status: InteractionDetailStatus.ready,
        analysis: analysis,
      );
    } on AnalysisApiException catch (error) {
      await _logger.logAnalysisLoadFailed(
        requestId: state.value.requestId,
        error: error,
        httpStatusCode: error.statusCode,
        errorCode: error.code?.value,
      );
      state.value = state.value.copyWith(
        status: InteractionDetailStatus.error,
        error: InteractionDetailError(
          httpStatusCode: error.statusCode,
          code: error.code,
        ),
      );
    } catch (_) {
      await _logger.logAnalysisLoadFailed(requestId: state.value.requestId);
      state.value = state.value.copyWith(
        status: InteractionDetailStatus.error,
        error: const InteractionDetailError(),
      );
    }
  }

  void dispose() {
    state.dispose();
  }
}
