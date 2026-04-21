import 'package:flutter/foundation.dart';

import 'package:app/screens/interaction_detail/interaction_detail_screen_state.dart';
import 'package:app/services/analysis_service.dart';

class InteractionDetailViewModel {
  InteractionDetailViewModel({
    required AnalysisService analysisService,
    required String requestId,
  }) : _analysisService = analysisService,
       state = ValueNotifier(
         InteractionDetailScreenState.initial(requestId: requestId),
       ) {
    load();
  }

  final AnalysisService _analysisService;
  final ValueNotifier<InteractionDetailScreenState> state;

  Future<void> load() async {
    state.value = state.value.copyWith(status: InteractionDetailStatus.loading);

    try {
      final analysis = await _analysisService.getRequestAnalysis(
        state.value.requestId,
      );
      state.value = state.value.copyWith(
        status: InteractionDetailStatus.ready,
        analysis: analysis,
      );
    } catch (_) {
      state.value = state.value.copyWith(status: InteractionDetailStatus.error);
    }
  }

  void dispose() {
    state.dispose();
  }
}
