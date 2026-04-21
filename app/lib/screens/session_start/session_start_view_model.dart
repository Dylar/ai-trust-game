import 'package:flutter/foundation.dart';

import 'package:app/models/session_models.dart';
import 'package:app/services/session_service.dart';
import 'package:app/screens/session_start/session_start_screen_state.dart';

class SessionStartViewModel {
  SessionStartViewModel({required this.sessionService})
    : state = ValueNotifier(SessionStartScreenState.initial());

  final SessionService sessionService;
  final ValueNotifier<SessionStartScreenState> state;

  void selectRole(Role role) {
    state.value = state.value.copyWith(selectedRole: role, resetStatus: true);
  }

  void selectMode(Mode mode) {
    state.value = state.value.copyWith(selectedMode: mode, resetStatus: true);
  }

  Future<void> prepareSession() async {
    state.value = state.value.copyWith(status: SessionStartStatus.loading);

    try {
      final session = await sessionService.startSession(
        role: state.value.selectedRole,
        mode: state.value.selectedMode,
      );

      state.value = state.value.copyWith(
        status: SessionStartStatus.prepared,
        createdSessionId: session.id,
      );
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
