import 'package:app/core/logging/app_logger.dart';

class InteractionLogger {
  const InteractionLogger({required this.appLogger});

  final AppLogger appLogger;

  Future<void> logSubmissionStarted({
    required String sessionId,
    required String message,
  }) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.info,
        category: 'interaction',
        message: 'Submitting interaction message',
        sessionId: sessionId,
        attributes: _messageAttributes(
          sessionId: sessionId,
          normalizedMessage: message,
        ),
      ),
    );
  }

  Future<void> logSubmissionSucceeded({
    required String sessionId,
    required String message,
    required String interactionId,
  }) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.info,
        category: 'interaction',
        message: 'Created interaction',
        sessionId: sessionId,
        attributes: <String, Object?>{
          ..._messageAttributes(
            sessionId: sessionId,
            normalizedMessage: message,
          ),
          'interactionId': interactionId,
        },
      ),
    );
  }

  Future<void> logSubmissionFailed({
    required String sessionId,
    required String message,
    Object? error,
    int? httpStatusCode,
    String? errorCode,
  }) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.error,
        category: 'interaction',
        message: 'Interaction submission failed',
        sessionId: sessionId,
        error: error,
        attributes: <String, Object?>{
          ..._messageAttributes(
            sessionId: sessionId,
            normalizedMessage: message,
          ),
          'httpStatusCode': httpStatusCode,
          'errorCode': errorCode,
        },
      ),
    );
  }

  Map<String, Object?> _messageAttributes({
    required String sessionId,
    required String normalizedMessage,
  }) {
    return <String, Object?>{
      'sessionId': sessionId,
      'messageLength': normalizedMessage.length,
    };
  }
}
