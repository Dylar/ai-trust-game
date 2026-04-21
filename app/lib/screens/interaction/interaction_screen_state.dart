import '../../models/interaction_models.dart';
import '../../models/session_models.dart';

enum InteractionScreenStatus { loading, ready, notFound, error }

class InteractionScreenState {
  const InteractionScreenState({
    required this.sessionId,
    required this.status,
    required this.session,
    required this.interactions,
  });

  factory InteractionScreenState.initial({required String sessionId}) {
    return InteractionScreenState(
      sessionId: sessionId,
      status: InteractionScreenStatus.loading,
      session: null,
      interactions: const <Interaction>[],
    );
  }

  final String sessionId;
  final InteractionScreenStatus status;
  final Session? session;
  final List<Interaction> interactions;

  InteractionScreenState copyWith({
    String? sessionId,
    InteractionScreenStatus? status,
    Session? session,
    List<Interaction>? interactions,
    bool resetSession = false,
  }) {
    return InteractionScreenState(
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      session: resetSession ? null : session ?? this.session,
      interactions: interactions ?? this.interactions,
    );
  }
}
