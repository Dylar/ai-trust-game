import 'package:flutter/foundation.dart';

import 'session_start_screen_state.dart';

class SessionStartViewModel {
  SessionStartViewModel()
    : state = ValueNotifier(SessionStartScreenState.initial());

  final ValueNotifier<SessionStartScreenState> state;

  void selectRole(SessionRole role) {
    state.value = state.value.copyWith(selectedRole: role, resetStatus: true);
  }

  void selectMode(SessionMode mode) {
    state.value = state.value.copyWith(selectedMode: mode, resetStatus: true);
  }

  Future<void> prepareSession() async {
    state.value = state.value.copyWith(status: SessionStartStatus.loading);

    // Keep a short artificial delay for now so the loading state is visible
    // while this screen still runs without the real backend request.
    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));

      state.value = state.value.copyWith(status: SessionStartStatus.prepared);
    } catch (_) {
      state.value = state.value.copyWith(
        status: SessionStartStatus.error,
        error: SessionStartError.unexpected,
      );
    }
  }

  void dispose() {
    state.dispose();
  }
}
