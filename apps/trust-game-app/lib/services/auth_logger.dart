import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/api/api_error.dart';

class AuthLogger {
  const AuthLogger({required this.appLogger});

  final AppLogger appLogger;

  Future<void> logUserProfileLoadFallback({
    required ApiException error,
    required StackTrace stackTrace,
  }) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.warning,
        category: 'auth',
        message: 'User profile load used local fallback',
        error: error,
        stackTrace: stackTrace,
        attributes: <String, Object?>{
          'httpStatusCode': error.statusCode,
          'errorCode': error.code?.value,
        },
      ),
    );
  }
}
