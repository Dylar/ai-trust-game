import 'package:app/models/analysis_models.dart';

enum InteractionDetailStatus { loading, ready, error }

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
  }) {
    return InteractionDetailScreenState(
      requestId: requestId,
      status: status ?? this.status,
      analysis: analysis ?? this.analysis,
    );
  }
}
