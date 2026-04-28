import 'package:app/core/logging/app_logger.dart';
import 'package:app/models/analysis_models.dart';

class SessionDetailLogger {
  const SessionDetailLogger({required this.appLogger});

  final AppLogger appLogger;

  Future<void> logAnalysisLoadStarted({required String sessionId}) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.info,
        category: 'session_detail',
        message: 'Loading session analysis',
        sessionId: sessionId,
        attributes: <String, Object?>{'sessionId': sessionId},
      ),
    );
  }

  Future<void> logAnalysisLoadSucceeded({required SessionAnalysis analysis}) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.info,
        category: 'session_detail',
        message: 'Loaded session analysis',
        sessionId: analysis.sessionId,
        attributes: <String, Object?>{
          'sessionId': analysis.sessionId,
          'requestCount': analysis.requestCount,
          'classification': analysis.classification,
        },
      ),
    );
  }

  Future<void> logAnalysisLoadFailed({
    required String sessionId,
    Object? error,
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
        attributes: <String, Object?>{
          'sessionId': sessionId,
          'httpStatusCode': httpStatusCode,
          'errorCode': errorCode,
        },
      ),
    );
  }
}
