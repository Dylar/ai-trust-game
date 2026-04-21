import '../../models/session_models.dart';

class InteractionScreenState {
  const InteractionScreenState({
    required this.sessionId,
    required this.session,
  });

  factory InteractionScreenState.initial({required String sessionId}) {
    return InteractionScreenState(sessionId: sessionId, session: null);
  }

  final String sessionId;
  final SessionSummary? session;

  bool get hasSession => session != null;

  InteractionScreenState copyWith({
    String? sessionId,
    SessionSummary? session,
    bool resetSession = false,
  }) {
    return InteractionScreenState(
      sessionId: sessionId ?? this.sessionId,
      session: resetSession ? null : session ?? this.session,
    );
  }
}
