import 'package:flutter/foundation.dart';

import '../../data/session/session_repository.dart';
import 'home_screen_state.dart';

class HomeViewModel {
  HomeViewModel({required SessionRepository sessionRepository})
    : _sessionRepository = sessionRepository,
      state = ValueNotifier(HomeScreenState.initial()) {
    _sessionRepository.sessionsListenable.addListener(_handleSessionsChanged);
    _handleSessionsChanged();
  }

  final SessionRepository _sessionRepository;
  final ValueNotifier<HomeScreenState> state;

  Future<void> _handleSessionsChanged() async {
    final sessions = await _sessionRepository.listSessions();

    state.value = state.value.copyWith(
      recentSessions: sessions
          .map(
            (session) =>
                SessionSummary(session: session, lastInteraction: null),
          )
          .toList(),
    );
  }

  void dispose() {
    _sessionRepository.sessionsListenable.removeListener(
      _handleSessionsChanged,
    );
    state.dispose();
  }
}
