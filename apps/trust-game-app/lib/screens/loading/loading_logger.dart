import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/api/api_error.dart';

class LoadingLogger {
  const LoadingLogger({required this.appLogger});

  final AppLogger appLogger;

  Future<void> logLoadingFailed({
    required String step,
    required Object error,
    required StackTrace stackTrace,
  }) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.error,
        category: 'loading',
        message: 'Startup loading failed',
        error: error,
        stackTrace: stackTrace,
        attributes: <String, Object?>{'step': step, ..._errorAttributes(error)},
      ),
    );
  }

  Map<String, Object?> _errorAttributes(Object error) {
    if (error is ApiException) {
      return <String, Object?>{
        'httpStatusCode': error.statusCode,
        'errorCode': error.code?.value,
      };
    }

    return const <String, Object?>{};
  }
}
