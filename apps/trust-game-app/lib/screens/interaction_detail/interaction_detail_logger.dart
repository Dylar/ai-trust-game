import 'package:app/core/logging/app_logger.dart';

class InteractionDetailLogger {
  const InteractionDetailLogger({required this.appLogger});

  final AppLogger appLogger;

  Future<void> logAnalysisLoadFailed({
    required String requestId,
    Object? error,
    StackTrace? stackTrace,
    int? httpStatusCode,
    String? errorCode,
  }) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.error,
        category: 'interaction_detail',
        message: 'Request analysis loading failed',
        error: error,
        stackTrace: stackTrace,
        attributes: <String, Object?>{
          'requestId': requestId,
          'httpStatusCode': httpStatusCode,
          'errorCode': errorCode,
        },
      ),
    );
  }
}
