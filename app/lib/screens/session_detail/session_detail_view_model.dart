import 'package:flutter/foundation.dart';

import 'package:app/screens/session_detail/session_detail_screen_state.dart';
import 'package:app/services/analysis_service.dart';

class SessionDetailViewModel {
  SessionDetailViewModel({
    required AnalysisService analysisService,
    required String sessionId,
  }) : _analysisService = analysisService,
       state = ValueNotifier(
         SessionDetailScreenState.initial(sessionId: sessionId),
       ) {
    load();
  }

  final AnalysisService _analysisService;
  final ValueNotifier<SessionDetailScreenState> state;

  Future<void> load() async {
    state.value = state.value.copyWith(status: SessionDetailStatus.loading);

    try {
      final analysis = await _analysisService.getSessionAnalysis(
        state.value.sessionId,
      );
      state.value = state.value.copyWith(
        status: SessionDetailStatus.ready,
        analysis: analysis,
      );
    } catch (_) {
      state.value = state.value.copyWith(status: SessionDetailStatus.error);
    }
  }

  void dispose() {
    state.dispose();
  }
}
