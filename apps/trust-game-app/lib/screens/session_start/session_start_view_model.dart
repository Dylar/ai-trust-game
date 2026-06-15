import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/models/session_models.dart';
import 'package:app/screens/session_start/session_start_logger.dart';
import 'package:app/screens/session_start/session_start_screen_state.dart';
import 'package:app/services/session_service.dart';
import 'package:flutter/foundation.dart';

class SessionStartViewModel {
  SessionStartViewModel({
    required AppLogger appLogger,
    required this.sessionService,
  }) : _logger = SessionStartLogger(appLogger: appLogger),
       stateNotifier = ValueNotifier(SessionStartScreenState.initial());

  final SessionStartLogger _logger;
  final SessionService sessionService;

  final ValueNotifier<SessionStartScreenState> stateNotifier;

  SessionStartScreenState get state => stateNotifier.value;

  void dispose() {
    stateNotifier.dispose();
  }

  void selectRole(Role role) {
    stateNotifier.value = state.copyWith(selectedRole: role, resetStatus: true);
  }

  void selectMode(Mode mode) {
    stateNotifier.value = state.copyWith(selectedMode: mode, resetStatus: true);
  }

  Future<void> prepareSession() async {
    stateNotifier.value = state.copyWith(status: SessionStartStatus.loading);

    try {
      final session = await sessionService.startSession(
        role: state.selectedRole,
        mode: state.selectedMode,
      );

      stateNotifier.value = state.copyWith(
        status: SessionStartStatus.prepared,
        createdSessionId: session.id,
      );
    } on ApiException catch (error, stackTrace) {
      await _logger.logPreparationFailed(
        role: state.selectedRole,
        mode: state.selectedMode,
        error: error,
        stackTrace: stackTrace,
        httpStatusCode: error.statusCode,
        errorCode: error.code?.value,
      );
      stateNotifier.value = state.copyWith(status: SessionStartStatus.error);
    } catch (error, stackTrace) {
      await _logger.logPreparationFailed(
        role: state.selectedRole,
        mode: state.selectedMode,
        error: error,
        stackTrace: stackTrace,
      );
      stateNotifier.value = state.copyWith(status: SessionStartStatus.error);
    }
  }
}
