import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/api/api_error.dart';
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
       stateNotifier = ValueNotifier(
         SessionDetailScreenState.initial(sessionId: sessionId),
       ) {
    loadSessionAnalysis();
  }

  final SessionDetailLogger _logger;
  final AnalysisService _analysisService;

  final ValueNotifier<SessionDetailScreenState> stateNotifier;
  SessionDetailScreenState get state => stateNotifier.value;

  void dispose() {
    stateNotifier.dispose();
  }

  Future<void> loadSessionAnalysis() async {
    stateNotifier.value = state.copyWith(status: SessionDetailStatus.loading);

    try {
      final analysis = await _analysisService.getSessionAnalysis(
        state.sessionId,
      );
      stateNotifier.value = state.copyWith(
        status: SessionDetailStatus.ready,
        analysis: analysis,
      );
    } on AnalysisApiException catch (error, stackTrace) {
      if (error.code == ApiErrorCode.sessionAnalysisNotFound) {
        stateNotifier.value = state.copyWith(
          status: SessionDetailStatus.notAvailableYet,
          resetAnalysis: true,
        );
        return;
      }

      await _logger.logAnalysisLoadFailed(
        sessionId: state.sessionId,
        error: error,
        stackTrace: stackTrace,
        httpStatusCode: error.statusCode,
        errorCode: error.code?.value,
      );
      stateNotifier.value = state.copyWith(status: SessionDetailStatus.error);
    } catch (error, stackTrace) {
      await _logger.logAnalysisLoadFailed(
        sessionId: state.sessionId,
        error: error,
        stackTrace: stackTrace,
      );
      stateNotifier.value = state.copyWith(status: SessionDetailStatus.error);
    }
  }
}
