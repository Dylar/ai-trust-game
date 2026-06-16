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

    final localAnalysis = await _analysisService.getSessionAnalysis(
      state.sessionId,
    );
    if (localAnalysis != null) {
      stateNotifier.value = state.copyWith(
        status: SessionDetailStatus.ready,
        analysis: localAnalysis,
        isRefreshing: true,
      );
    } else {
      stateNotifier.value = state.copyWith(isRefreshing: true);
    }

    try {
      await _analysisService.refreshSessionAnalysis(state.sessionId);
      final analysis = await _analysisService.getSessionAnalysis(
        state.sessionId,
      );
      if (analysis == null) {
        stateNotifier.value = state.copyWith(
          status: SessionDetailStatus.notAvailableYet,
          resetAnalysis: true,
          isRefreshing: false,
        );
        return;
      }

      stateNotifier.value = state.copyWith(
        status: SessionDetailStatus.ready,
        analysis: analysis,
        isRefreshing: false,
      );
    } on AnalysisApiException catch (error, stackTrace) {
      if (error.code == ApiErrorCode.sessionAnalysisNotFound) {
        if (localAnalysis != null) {
          stateNotifier.value = state.copyWith(isRefreshing: false);
          return;
        }

        stateNotifier.value = state.copyWith(
          status: SessionDetailStatus.notAvailableYet,
          resetAnalysis: true,
          isRefreshing: false,
        );
        return;
      }

      if (localAnalysis != null) {
        await _logger.logAnalysisLoadFailed(
          sessionId: state.sessionId,
          error: error,
          stackTrace: stackTrace,
          httpStatusCode: error.statusCode,
          errorCode: error.code?.value,
        );
        stateNotifier.value = state.copyWith(isRefreshing: false);
        return;
      }

      await _logger.logAnalysisLoadFailed(
        sessionId: state.sessionId,
        error: error,
        stackTrace: stackTrace,
        httpStatusCode: error.statusCode,
        errorCode: error.code?.value,
      );
      stateNotifier.value = state.copyWith(
        status: SessionDetailStatus.error,
        isRefreshing: false,
      );
    } catch (error, stackTrace) {
      if (localAnalysis != null) {
        await _logger.logAnalysisLoadFailed(
          sessionId: state.sessionId,
          error: error,
          stackTrace: stackTrace,
        );
        stateNotifier.value = state.copyWith(isRefreshing: false);
        return;
      }

      await _logger.logAnalysisLoadFailed(
        sessionId: state.sessionId,
        error: error,
        stackTrace: stackTrace,
      );
      stateNotifier.value = state.copyWith(
        status: SessionDetailStatus.error,
        isRefreshing: false,
      );
    }
  }
}
