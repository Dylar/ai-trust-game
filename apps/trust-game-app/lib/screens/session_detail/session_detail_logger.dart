import 'package:app/core/logging/app_logger.dart';

class SessionDetailLogger {
  const SessionDetailLogger({required this.appLogger});

  final AppLogger appLogger;

  Future<void> logAnalysisLoadFailed({
    required String sessionId,
    Object? error,
    StackTrace? stackTrace,
    int? httpStatusCode,
    String? errorCode,
  }) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.error,
        category: 'session_detail',
        message: 'Session analysis loading failed',
        sessionId: sessionId,
        error: error,
        stackTrace: stackTrace,
        attributes: <String, Object?>{
          'sessionId': sessionId,
          'httpStatusCode': httpStatusCode,
          'errorCode': errorCode,
        },
      ),
    );
  }
}
