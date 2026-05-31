import 'package:app/data/api/api_error.dart';
import 'package:app/models/session_models.dart';
import 'package:app/services/session_service.dart';

class SuccessfulSessionService implements SessionService {
  const SuccessfulSessionService({
    this.sessionId = 'session-1',
    this.role,
    this.mode,
  });

  final String sessionId;
  final Role? role;
  final Mode? mode;

  @override
  Future<Session> startSession({required Role role, required Mode mode}) async {
    return Session(
      id: sessionId,
      role: this.role ?? role,
      mode: this.mode ?? mode,
    );
  }
}

class ApiFailingSessionService implements SessionService {
  const ApiFailingSessionService({
    required this.statusCode,
    required this.code,
  });

  final int statusCode;
  final ApiErrorCode code;

  @override
  Future<Session> startSession({required Role role, required Mode mode}) {
    throw ApiException(
      statusCode: statusCode,
      error: ApiError(code: code),
    );
  }
}
