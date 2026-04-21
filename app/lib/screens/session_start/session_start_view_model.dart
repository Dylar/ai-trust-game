import 'package:flutter/foundation.dart';

import '../../models/session_models.dart';
import '../../services/session_service.dart';
import '../../models/start_session_models.dart';
import 'session_start_screen_state.dart';

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
    final request = StartSessionRequest(
      role: state.value.selectedRole,
      mode: state.value.selectedMode,
    );

    state.value = state.value.copyWith(status: SessionStartStatus.loading);

    try {
      final result = await sessionService.startSession(request);

      state.value = state.value.copyWith(
        status: SessionStartStatus.prepared,
        createdSessionId: result.sessionId,
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
