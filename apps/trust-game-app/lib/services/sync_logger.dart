import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/services/sync_service.dart';

class SyncLogger {
  const SyncLogger({required this.appLogger});

  final AppLogger appLogger;

  Future<void> logUserSyncFailed({
    required UserProfile user,
    required SyncStatus status,
    required ApiException error,
    required StackTrace stackTrace,
  }) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.warning,
        category: 'sync',
        message: 'User sync failed',
        error: error,
        stackTrace: stackTrace,
        attributes: <String, Object?>{
          'userId': user.id,
          'syncStatus': status.name,
          'httpStatusCode': error.statusCode,
          'errorCode': error.code?.value,
        },
      ),
    );
  }
}
