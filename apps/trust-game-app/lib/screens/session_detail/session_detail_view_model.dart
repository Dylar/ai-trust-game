import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/screens/session_detail/session_detail_logger.dart';
import 'package:app/screens/session_detail/session_detail_screen_state.dart';
import 'package:app/services/analysis_service.dart';
import 'package:flutter/foundation.dart';

class SessionDetailViewModel {
  SessionDetailViewModel({
    required AppLogger appLogger,
    required AnalysisService analysisService,
    required String sessionId,
  }) : _analysisService = analysisService,
       _logger = SessionDetailLogger(appLogger: appLogger),
       state = ValueNotifier(
         SessionDetailScreenState.initial(sessionId: sessionId),
       ) {
    loadSessionAnalysis();
  }

  final AnalysisService _analysisService;
  final SessionDetailLogger _logger;
  final ValueNotifier<SessionDetailScreenState> state;

  Future<void> loadSessionAnalysis() async {
    state.value = state.value.copyWith(
      status: SessionDetailStatus.loading,
      resetError: true,
    );
    await _logger.logAnalysisLoadStarted(sessionId: state.value.sessionId);

    try {
      final analysis = await _analysisService.getSessionAnalysis(
        state.value.sessionId,
      );
      await _logger.logAnalysisLoadSucceeded(analysis: analysis);
      state.value = state.value.copyWith(
        status: SessionDetailStatus.ready,
        analysis: analysis,
      );
    } on AnalysisApiException catch (error) {
      await _logger.logAnalysisLoadFailed(
        sessionId: state.value.sessionId,
        error: error,
        httpStatusCode: error.statusCode,
        errorCode: error.code?.value,
      );
      state.value = state.value.copyWith(
        status: SessionDetailStatus.error,
        error: SessionDetailError(
          httpStatusCode: error.statusCode,
          code: error.code,
        ),
      );
    } catch (_) {
      await _logger.logAnalysisLoadFailed(sessionId: state.value.sessionId);
      state.value = state.value.copyWith(
        status: SessionDetailStatus.error,
        error: const SessionDetailError(),
      );
    }
  }

  void dispose() {
    state.dispose();
  }
}
