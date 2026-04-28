import 'package:flutter/foundation.dart';

import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/models/session_models.dart';
import 'package:app/screens/session_start/session_start_logger.dart';
import 'package:app/screens/session_start/session_start_screen_state.dart';
import 'package:app/services/session_service.dart';

class SessionStartViewModel {
  SessionStartViewModel({required AppLogger appLogger, required this.sessionService})
    : _logger = SessionStartLogger(appLogger: appLogger),
      state = ValueNotifier(SessionStartScreenState.initial());

  final SessionStartLogger _logger;
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
    await _logger.logPreparationStarted(
      role: state.value.selectedRole,
      mode: state.value.selectedMode,
    );

    try {
      final session = await sessionService.startSession(
        role: state.value.selectedRole,
        mode: state.value.selectedMode,
      );
      await _logger.logPreparationSucceeded(session: session);

      state.value = state.value.copyWith(
        status: SessionStartStatus.prepared,
        createdSessionId: session.id,
      );
    } on ApiException catch (error) {
      await _logger.logPreparationFailed(
        role: state.value.selectedRole,
        mode: state.value.selectedMode,
        error: error,
        httpStatusCode: error.statusCode,
        errorCode: error.code?.value,
      );
      state.value = state.value.copyWith(
        status: SessionStartStatus.error,
        error: SessionStartError(
          httpStatusCode: error.statusCode,
          code: error.code,
        ),
      );
    } catch (_) {
      await _logger.logPreparationFailed(
        role: state.value.selectedRole,
        mode: state.value.selectedMode,
      );
      state.value = state.value.copyWith(
        status: SessionStartStatus.error,
        error: const SessionStartError(),
      );
    }
  }

  void dispose() {
    state.dispose();
  }
}
