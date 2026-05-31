import 'package:app/core/logging/app_logger.dart';
import 'package:app/models/session_models.dart';

class SessionStartLogger {
  const SessionStartLogger({required this.appLogger});

  final AppLogger appLogger;

  Future<void> logPreparationStarted({
    required Role role,
    required Mode mode,
  }) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.info,
        category: 'session_start',
        message: 'Preparing session',
        attributes: _selectionAttributes(role: role, mode: mode),
      ),
    );
  }

  Future<void> logPreparationSucceeded({required Session session}) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.info,
        category: 'session_start',
        message: 'Prepared session',
        sessionId: session.id,
        attributes: <String, Object?>{
          'sessionId': session.id,
          'role': session.role.name,
          'mode': session.mode.name,
        },
      ),
    );
  }

  Future<void> logPreparationFailed({
    required Role role,
    required Mode mode,
    Object? error,
    int? httpStatusCode,
    String? errorCode,
  }) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.error,
        category: 'session_start',
        message: 'Session preparation failed',
        error: error,
        attributes: <String, Object?>{
          ..._selectionAttributes(role: role, mode: mode),
          'httpStatusCode': httpStatusCode,
          'errorCode': errorCode,
        },
      ),
    );
  }

  Map<String, Object?> _selectionAttributes({
    required Role role,
    required Mode mode,
  }) {
    return <String, Object?>{'role': role.name, 'mode': mode.name};
  }
}
