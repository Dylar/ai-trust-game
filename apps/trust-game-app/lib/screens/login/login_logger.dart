import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:app/data/api/api_error.dart';

class LoginLogger {
  const LoginLogger({required this.appLogger});

  final AppLogger appLogger;

  Future<void> logUserListLoadFailed({
    required Object error,
    required StackTrace stackTrace,
  }) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.error,
        category: 'login',
        message: 'Login user list load failed',
        error: error,
        stackTrace: stackTrace,
        attributes: _errorAttributes(error),
      ),
    );
  }

  Future<void> logUserSelectionFailed({
    required UserProfile user,
    required Object error,
    required StackTrace stackTrace,
  }) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.error,
        category: 'login',
        message: 'Login user selection failed',
        error: error,
        stackTrace: stackTrace,
        attributes: <String, Object?>{
          ..._userAttributes(user),
          ..._errorAttributes(error),
        },
      ),
    );
  }

  Future<void> logUserCreationFailed({
    required String displayName,
    required Object error,
    required StackTrace stackTrace,
  }) {
    return appLogger.log(
      AppLogEvent(
        level: AppLogLevel.error,
        category: 'login',
        message: 'Login user creation failed',
        error: error,
        stackTrace: stackTrace,
        attributes: <String, Object?>{
          'displayNameLength': displayName.length,
          ..._errorAttributes(error),
        },
      ),
    );
  }

  Map<String, Object?> _userAttributes(UserProfile user) {
    return <String, Object?>{'userId': user.id, 'isLoaded': user.isLoaded};
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
