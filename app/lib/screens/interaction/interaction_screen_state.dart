import 'package:app/data/api/api_error.dart';
import 'package:app/models/interaction_models.dart';
import 'package:app/models/session_models.dart';

enum InteractionScreenStatus { loading, ready, notFound, error }

class InteractionScreenError {
  const InteractionScreenError({this.httpStatusCode, this.code});

  final int? httpStatusCode;
  final ApiErrorCode? code;
}

class InteractionScreenState {
  const InteractionScreenState({
    required this.sessionId,
    required this.status,
    required this.session,
    required this.interactions,
    required this.isSubmitting,
    required this.error,
  });

  factory InteractionScreenState.initial({required String sessionId}) {
    return InteractionScreenState(
      sessionId: sessionId,
      status: InteractionScreenStatus.loading,
      session: null,
      interactions: const <Interaction>[],
      isSubmitting: false,
      error: null,
    );
  }

  final String sessionId;
  final InteractionScreenStatus status;
  final Session? session;
  final List<Interaction> interactions;
  final bool isSubmitting;
  final InteractionScreenError? error;

  InteractionScreenState copyWith({
    String? sessionId,
    InteractionScreenStatus? status,
    Session? session,
    List<Interaction>? interactions,
    bool? isSubmitting,
    InteractionScreenError? error,
    bool resetSession = false,
    bool resetError = false,
  }) {
    return InteractionScreenState(
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      session: resetSession ? null : session ?? this.session,
      interactions: interactions ?? this.interactions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: resetError ? null : error ?? this.error,
    );
  }
}
