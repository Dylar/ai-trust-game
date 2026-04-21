import 'package:flutter/foundation.dart';

import '../../data/interaction/interaction_repository.dart';
import '../../data/session/session_repository.dart';
import 'interaction_screen_state.dart';

class InteractionViewModel {
  InteractionViewModel({
    required InteractionRepository interactionRepository,
    required SessionRepository sessionRepository,
    required String sessionId,
  }) : _interactionRepository = interactionRepository,
       _sessionRepository = sessionRepository,
       state = ValueNotifier(
         InteractionScreenState.initial(sessionId: sessionId),
       ) {
    _loadSessionData();
  }

  final InteractionRepository _interactionRepository;
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

  void dispose() {
    state.dispose();
  }
}
