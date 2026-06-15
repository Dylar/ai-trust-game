import 'package:app/core/logging/app_logger.dart';

class InteractionLogger {
  const InteractionLogger({required this.appLogger});

  final AppLogger appLogger;

  Future<void> logLoadFailed({
    required String sessionId,
    required Object error,
    required StackTrace stackTrace,
  }) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.error,
        category: 'interaction',
        message: 'Interaction loading failed',
        sessionId: sessionId,
        error: error,
        stackTrace: stackTrace,
        attributes: <String, Object?>{'sessionId': sessionId},
      ),
    );
  }

  Future<void> logSubmissionFailed({
    required String sessionId,
    required String message,
    Object? error,
    StackTrace? stackTrace,
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
        stackTrace: stackTrace,
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
