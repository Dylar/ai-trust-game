import 'package:app/data/api/api_error.dart';
import 'package:app/models/analysis_models.dart';

enum InteractionDetailStatus { loading, ready, error }

class InteractionDetailError {
  const InteractionDetailError({this.httpStatusCode, this.code});

  final int? httpStatusCode;
  final ApiErrorCode? code;
}

class InteractionDetailScreenState {
  const InteractionDetailScreenState({
    required this.requestId,
    required this.status,
    required this.analysis,
    required this.error,
  });

  factory InteractionDetailScreenState.initial({required String requestId}) {
    return InteractionDetailScreenState(
      requestId: requestId,
      status: InteractionDetailStatus.loading,
      analysis: null,
      error: null,
    );
  }

  final String requestId;
  final InteractionDetailStatus status;
  final RequestAnalysis? analysis;
  final InteractionDetailError? error;

  InteractionDetailScreenState copyWith({
    InteractionDetailStatus? status,
    RequestAnalysis? analysis,
    InteractionDetailError? error,
    bool resetError = false,
  }) {
    return InteractionDetailScreenState(
      requestId: requestId,
      status: status ?? this.status,
      analysis: analysis ?? this.analysis,
      error: resetError ? null : error ?? this.error,
    );
  }
}
