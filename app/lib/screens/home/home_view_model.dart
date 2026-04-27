import 'package:flutter/foundation.dart';

import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/screens/home/home_screen_state.dart';

class HomeViewModel {
  HomeViewModel({
    required InteractionRepository interactionRepository,
    required SessionRepository sessionRepository,
  }) : _interactionRepository = interactionRepository,
       _sessionRepository = sessionRepository,
       state = ValueNotifier(HomeScreenState.initial()) {
    _sessionRepository.sessionsListenable.addListener(_handleSessionsChanged);
    _interactionRepository.changes.addListener(_handleSessionsChanged);
    _handleSessionsChanged();
  }

  final InteractionRepository _interactionRepository;
  final SessionRepository _sessionRepository;
  final ValueNotifier<HomeScreenState> state;

  Future<void> _handleSessionsChanged() async {
    final sessions = await _sessionRepository.listSessions();
    final summaries = <SessionSummary>[];

    for (final session in sessions) {
      final lastInteraction = await _interactionRepository.getLastInteraction(
        session.id,
      );

      summaries.add(
        SessionSummary(session: session, lastInteraction: lastInteraction),
      );
    }

    state.value = state.value.copyWith(recentSessions: summaries);
  }

  void dispose() {
    _interactionRepository.changes.removeListener(_handleSessionsChanged);
    _sessionRepository.sessionsListenable.removeListener(
      _handleSessionsChanged,
    );
    state.dispose();
  }
}
