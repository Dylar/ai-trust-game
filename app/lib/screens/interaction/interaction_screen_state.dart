import '../../models/interaction_models.dart';
import '../../models/session_models.dart';

enum InteractionScreenStatus { loading, ready, notFound, error }

class InteractionScreenState {
  const InteractionScreenState({
    required this.sessionId,
    required this.status,
    required this.session,
    required this.interactions,
    required this.isSubmitting,
  });

  factory InteractionScreenState.initial({required String sessionId}) {
    return InteractionScreenState(
      sessionId: sessionId,
      status: InteractionScreenStatus.loading,
      session: null,
      interactions: const <Interaction>[],
      isSubmitting: false,
    );
  }

  final String sessionId;
  final InteractionScreenStatus status;
  final Session? session;
  final List<Interaction> interactions;
  final bool isSubmitting;

  InteractionScreenState copyWith({
    String? sessionId,
    InteractionScreenStatus? status,
    Session? session,
    List<Interaction>? interactions,
    bool? isSubmitting,
    bool resetSession = false,
  }) {
    return InteractionScreenState(
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      session: resetSession ? null : session ?? this.session,
      interactions: interactions ?? this.interactions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
