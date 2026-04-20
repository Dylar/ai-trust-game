import 'package:flutter/foundation.dart';

import 'session_start_screen_state.dart';

class SessionStartViewModel {
  SessionStartViewModel()
    : state = ValueNotifier(SessionStartScreenState.initial());

  final ValueNotifier<SessionStartScreenState> state;

  void selectRole(SessionRole role) {
    state.value = state.value.copyWith(
      selectedRole: role,
      clearStatusMessage: true,
    );
  }

  void selectMode(SessionMode mode) {
    state.value = state.value.copyWith(
      selectedMode: mode,
      clearStatusMessage: true,
    );
  }

  Future<void> prepareSession() async {
    state.value = state.value.copyWith(
      isSubmitting: true,
      clearStatusMessage: true,
    );

    await Future<void>.delayed(const Duration(milliseconds: 250));

    final currentState = state.value;
    state.value = currentState.copyWith(
      isSubmitting: false,
      statusMessage:
          'Prepared ${currentState.selectedRole.label} session in '
          '${currentState.selectedMode.label} mode. Backend start comes next.',
    );
  }

  void dispose() {
    state.dispose();
  }
}
