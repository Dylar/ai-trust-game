import 'package:app/models/analysis_models.dart';

enum SessionDetailStatus { loading, ready, notAvailableYet, error }

class SessionDetailScreenState {
  const SessionDetailScreenState({
    required this.sessionId,
    required this.status,
    required this.analysis,
    required this.isRefreshing,
  });

  factory SessionDetailScreenState.initial({required String sessionId}) {
    return SessionDetailScreenState(
      sessionId: sessionId,
      status: SessionDetailStatus.loading,
      analysis: null,
      isRefreshing: false,
    );
  }

  final String sessionId;
  final SessionDetailStatus status;
  final SessionAnalysis? analysis;
  final bool isRefreshing;

  SessionDetailScreenState copyWith({
    SessionDetailStatus? status,
    SessionAnalysis? analysis,
    bool? isRefreshing,
    bool resetAnalysis = false,
  }) {
    return SessionDetailScreenState(
      sessionId: sessionId,
      status: status ?? this.status,
      analysis: resetAnalysis ? null : analysis ?? this.analysis,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
