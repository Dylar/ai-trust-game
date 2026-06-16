import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/api/api_error.dart';
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
       stateNotifier = ValueNotifier(
         InteractionDetailScreenState.initial(requestId: requestId),
       ) {
    loadRequestAnalysis();
  }

  final InteractionDetailLogger _logger;
  final AnalysisService _analysisService;

  final ValueNotifier<InteractionDetailScreenState> stateNotifier;

  InteractionDetailScreenState get state => stateNotifier.value;

  void dispose() {
    stateNotifier.dispose();
  }

  Future<void> loadRequestAnalysis() async {
    stateNotifier.value = state.copyWith(
      status: InteractionDetailStatus.loading,
    );

    final localAnalysis = await _analysisService.getRequestAnalysis(
      state.requestId,
    );
    if (localAnalysis != null) {
      stateNotifier.value = state.copyWith(
        status: InteractionDetailStatus.ready,
        analysis: localAnalysis,
        isRefreshing: true,
      );
    } else {
      stateNotifier.value = state.copyWith(isRefreshing: true);
    }

    try {
      await _analysisService.refreshRequestAnalysis(state.requestId);
      final analysis = await _analysisService.getRequestAnalysis(
        state.requestId,
      );
      if (analysis == null) {
        stateNotifier.value = state.copyWith(
          status: InteractionDetailStatus.notAvailableYet,
          resetAnalysis: true,
          isRefreshing: false,
        );
        return;
      }

      stateNotifier.value = state.copyWith(
        status: InteractionDetailStatus.ready,
        analysis: analysis,
        isRefreshing: false,
      );
    } on AnalysisApiException catch (error, stackTrace) {
      if (error.code == ApiErrorCode.requestAnalysisNotFound) {
        if (localAnalysis != null) {
          stateNotifier.value = state.copyWith(isRefreshing: false);
          return;
        }

        stateNotifier.value = state.copyWith(
          status: InteractionDetailStatus.notAvailableYet,
          resetAnalysis: true,
          isRefreshing: false,
        );
        return;
      }

      if (localAnalysis != null) {
        await _logger.logAnalysisLoadFailed(
          requestId: state.requestId,
          error: error,
          stackTrace: stackTrace,
          httpStatusCode: error.statusCode,
          errorCode: error.code?.value,
        );
        stateNotifier.value = state.copyWith(isRefreshing: false);
        return;
      }

      await _logger.logAnalysisLoadFailed(
        requestId: state.requestId,
        error: error,
        stackTrace: stackTrace,
        httpStatusCode: error.statusCode,
        errorCode: error.code?.value,
      );
      stateNotifier.value = state.copyWith(
        status: InteractionDetailStatus.error,
        isRefreshing: false,
      );
    } catch (error, stackTrace) {
      if (localAnalysis != null) {
        await _logger.logAnalysisLoadFailed(
          requestId: state.requestId,
          error: error,
          stackTrace: stackTrace,
        );
        stateNotifier.value = state.copyWith(isRefreshing: false);
        return;
      }

      await _logger.logAnalysisLoadFailed(
        requestId: state.requestId,
        error: error,
        stackTrace: stackTrace,
      );
      stateNotifier.value = state.copyWith(
        status: InteractionDetailStatus.error,
        isRefreshing: false,
      );
    }
  }
}
