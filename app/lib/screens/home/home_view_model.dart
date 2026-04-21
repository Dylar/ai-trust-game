import 'package:flutter/foundation.dart';

import '../../data/session/session_repository.dart';
import 'home_screen_state.dart';

class HomeViewModel {
  HomeViewModel({required SessionRepository sessionRepository})
    : _sessionRepository = sessionRepository,
      state = ValueNotifier(HomeScreenState.initial()) {
    _sessionRepository.recentSessionsListenable.addListener(
      _handleSessionsChanged,
    );
    _handleSessionsChanged();
  }

  final SessionRepository _sessionRepository;
  final ValueNotifier<HomeScreenState> state;

  Future<void> _handleSessionsChanged() async {
    final recentSessions = await _sessionRepository.listRecentSessions();

    state.value = state.value.copyWith(recentSessions: recentSessions);
  }

  void dispose() {
    _sessionRepository.recentSessionsListenable.removeListener(
      _handleSessionsChanged,
    );
    state.dispose();
  }
}
