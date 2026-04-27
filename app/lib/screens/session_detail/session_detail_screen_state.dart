import 'package:app/data/api/api_error.dart';
import 'package:app/models/analysis_models.dart';

enum SessionDetailStatus { loading, ready, error }

class SessionDetailError {
  const SessionDetailError({this.httpStatusCode, this.code});

  final int? httpStatusCode;
  final ApiErrorCode? code;
}

class SessionDetailScreenState {
  const SessionDetailScreenState({
    required this.sessionId,
    required this.status,
    required this.analysis,
    required this.error,
  });

  factory SessionDetailScreenState.initial({required String sessionId}) {
    return SessionDetailScreenState(
      sessionId: sessionId,
      status: SessionDetailStatus.loading,
      analysis: null,
      error: null,
    );
  }

  final String sessionId;
  final SessionDetailStatus status;
  final SessionAnalysis? analysis;
  final SessionDetailError? error;

  SessionDetailScreenState copyWith({
    SessionDetailStatus? status,
    SessionAnalysis? analysis,
    SessionDetailError? error,
    bool resetError = false,
  }) {
    return SessionDetailScreenState(
      sessionId: sessionId,
      status: status ?? this.status,
      analysis: analysis ?? this.analysis,
      error: resetError ? null : error ?? this.error,
    );
  }
}
