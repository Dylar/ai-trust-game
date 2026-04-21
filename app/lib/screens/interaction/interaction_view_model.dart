import 'package:flutter/foundation.dart';

import '../../data/session/session_repository.dart';
import 'interaction_screen_state.dart';

class InteractionViewModel {
  InteractionViewModel({
    required SessionRepository sessionRepository,
    required String sessionId,
  }) : _sessionRepository = sessionRepository,
       state = ValueNotifier(
         InteractionScreenState.initial(sessionId: sessionId),
       ) {
    _loadSession();
  }

  final SessionRepository _sessionRepository;
  final ValueNotifier<InteractionScreenState> state;

  void _loadSession() {
    state.value = state.value.copyWith(
      session: _sessionRepository.getSession(state.value.sessionId),
    );
  }

  void dispose() {
    state.dispose();
  }
}
