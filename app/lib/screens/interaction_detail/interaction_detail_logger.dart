import 'package:app/core/logging/app_logger.dart';
import 'package:app/models/analysis_models.dart';

class InteractionDetailLogger {
  const InteractionDetailLogger({required this.appLogger});

  final AppLogger appLogger;

  Future<void> logAnalysisLoadStarted({required String requestId}) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.info,
        category: 'interaction_detail',
        message: 'Loading request analysis',
        attributes: <String, Object?>{'requestId': requestId},
      ),
    );
  }

  Future<void> logAnalysisLoadSucceeded({required RequestAnalysis analysis}) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.info,
        category: 'interaction_detail',
        message: 'Loaded request analysis',
        sessionId: analysis.sessionId,
        attributes: <String, Object?>{
          'requestId': analysis.requestId,
          'sessionId': analysis.sessionId,
          'classification': analysis.classification,
        },
      ),
    );
  }

  Future<void> logAnalysisLoadFailed({
    required String requestId,
    Object? error,
    int? httpStatusCode,
    String? errorCode,
  }) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.error,
        category: 'interaction_detail',
        message: 'Request analysis loading failed',
        error: error,
        attributes: <String, Object?>{
          'requestId': requestId,
          'httpStatusCode': httpStatusCode,
          'errorCode': errorCode,
        },
      ),
    );
  }
}
