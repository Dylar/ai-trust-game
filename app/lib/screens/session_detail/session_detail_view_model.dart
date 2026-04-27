import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/screens/session_detail/session_detail_screen_state.dart';
import 'package:app/services/analysis_service.dart';
import 'package:flutter/foundation.dart';

class SessionDetailViewModel {
  SessionDetailViewModel({
    required AnalysisService analysisService,
    required String sessionId,
  }) : _analysisService = analysisService,
       state = ValueNotifier(
         SessionDetailScreenState.initial(sessionId: sessionId),
       ) {
    loadSessionAnalysis();
  }

  final AnalysisService _analysisService;
  final ValueNotifier<SessionDetailScreenState> state;

  Future<void> loadSessionAnalysis() async {
    state.value = state.value.copyWith(
      status: SessionDetailStatus.loading,
      resetError: true,
    );

    try {
      final analysis = await _analysisService.getSessionAnalysis(
        state.value.sessionId,
      );
      state.value = state.value.copyWith(
        status: SessionDetailStatus.ready,
        analysis: analysis,
      );
    } on AnalysisApiException catch (error) {
      state.value = state.value.copyWith(
        status: SessionDetailStatus.error,
        error: SessionDetailError(
          httpStatusCode: error.statusCode,
          code: error.code,
        ),
      );
    } catch (_) {
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
