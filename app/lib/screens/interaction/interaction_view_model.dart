import 'package:flutter/foundation.dart';

import '../../data/interaction/interaction_repository.dart';
import '../../data/session/session_repository.dart';
import '../../services/interaction_service.dart';
import 'interaction_screen_state.dart';

class InteractionViewModel {
  InteractionViewModel({
    required InteractionRepository interactionRepository,
    required InteractionService interactionService,
    required SessionRepository sessionRepository,
    required String sessionId,
  }) : _interactionRepository = interactionRepository,
       _interactionService = interactionService,
       _sessionRepository = sessionRepository,
       state = ValueNotifier(
         InteractionScreenState.initial(sessionId: sessionId),
       ) {
    _loadSessionData();
  }

  final InteractionRepository _interactionRepository;
  final InteractionService _interactionService;
  final SessionRepository _sessionRepository;
  final ValueNotifier<InteractionScreenState> state;

  Future<void> _loadSessionData() async {
    try {
      final session = await _sessionRepository.getSession(
        state.value.sessionId,
      );

      if (session == null) {
        state.value = state.value.copyWith(
          status: InteractionScreenStatus.notFound,
          resetSession: true,
        );
        return;
      }

      final interactions = await _interactionRepository.listInteractions(
        state.value.sessionId,
      );

      state.value = state.value.copyWith(
        status: InteractionScreenStatus.ready,
        session: session,
        interactions: interactions,
      );
    } catch (_) {
      state.value = state.value.copyWith(
        status: InteractionScreenStatus.error,
        resetSession: true,
      );
    }
  }

  Future<void> submitMessage(String message) async {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty ||
        state.value.status != InteractionScreenStatus.ready ||
        state.value.isSubmitting) {
      return;
    }

    state.value = state.value.copyWith(isSubmitting: true);

    try {
      await _interactionService.createInteraction(
        sessionId: state.value.sessionId,
        message: normalizedMessage,
      );
      final interactions = await _interactionRepository.listInteractions(
        state.value.sessionId,
      );

      state.value = state.value.copyWith(
        interactions: interactions,
        isSubmitting: false,
      );
    } catch (_) {
      state.value = state.value.copyWith(
        status: InteractionScreenStatus.error,
        isSubmitting: false,
      );
    }
  }

  void dispose() {
    state.dispose();
  }
}
