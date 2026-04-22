import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/screens/interaction_detail/interaction_detail_screen_state.dart';
import 'package:app/services/analysis_service.dart';
import 'package:flutter/foundation.dart';

class InteractionDetailViewModel {
  InteractionDetailViewModel({
    required AnalysisService analysisService,
    required String requestId,
  }) : _analysisService = analysisService,
       state = ValueNotifier(
         InteractionDetailScreenState.initial(requestId: requestId),
       ) {
    loadRequestAnalysis();
  }

  final AnalysisService _analysisService;
  final ValueNotifier<InteractionDetailScreenState> state;

  Future<void> loadRequestAnalysis() async {
    state.value = state.value.copyWith(
      status: InteractionDetailStatus.loading,
      resetError: true,
    );

    try {
      final analysis = await _analysisService.getRequestAnalysis(
        state.value.requestId,
      );
      state.value = state.value.copyWith(
        status: InteractionDetailStatus.ready,
        analysis: analysis,
      );
    } on AnalysisApiException catch (error) {
      state.value = state.value.copyWith(
        status: InteractionDetailStatus.error,
        error: InteractionDetailError(httpStatusCode: error.statusCode),
      );
    } catch (_) {
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
