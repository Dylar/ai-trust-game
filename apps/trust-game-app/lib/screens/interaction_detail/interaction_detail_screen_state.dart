import 'package:app/models/analysis_models.dart';

enum InteractionDetailStatus { loading, ready, notAvailableYet, error }

class InteractionDetailScreenState {
  const InteractionDetailScreenState({
    required this.requestId,
    required this.status,
    required this.analysis,
  });

  factory InteractionDetailScreenState.initial({required String requestId}) {
    return InteractionDetailScreenState(
      requestId: requestId,
      status: InteractionDetailStatus.loading,
      analysis: null,
    );
  }

  final String requestId;
  final InteractionDetailStatus status;
  final RequestAnalysis? analysis;

  InteractionDetailScreenState copyWith({
    InteractionDetailStatus? status,
    RequestAnalysis? analysis,
    bool resetAnalysis = false,
  }) {
    return InteractionDetailScreenState(
      requestId: requestId,
      status: status ?? this.status,
      analysis: resetAnalysis ? null : analysis ?? this.analysis,
    );
  }
}
