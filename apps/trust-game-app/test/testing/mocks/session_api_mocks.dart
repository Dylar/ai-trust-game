import 'package:app/data/api/api_error.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/start_session_dto.dart';
import 'package:app/models/session_models.dart';

class SuccessfulSessionApi implements SessionApi {
  const SuccessfulSessionApi({
    this.sessionId = 'session-1',
    this.role,
    this.mode,
  });

  final String sessionId;
  final Role? role;
  final Mode? mode;

  @override
  Future<ListSessionsResponse> listSessionsForUser(String userId) async {
    return const ListSessionsResponse(sessions: <Session>[]);
  }

  @override
  Future<StartSessionResponse> startSession(StartSessionRequest request) async {
    return StartSessionResponse(
      sessionId: sessionId,
      role: role ?? request.role,
      mode: mode ?? request.mode,
    );
  }
}

class ApiFailingSessionApi implements SessionApi {
  const ApiFailingSessionApi({required this.statusCode, required this.code});

  final int statusCode;
  final ApiErrorCode code;

  @override
  Future<ListSessionsResponse> listSessionsForUser(String userId) async {
    return const ListSessionsResponse(sessions: <Session>[]);
  }

  @override
  Future<StartSessionResponse> startSession(StartSessionRequest request) {
    throw SessionApiException(
      statusCode: statusCode,
      error: ApiError(code: code),
    );
  }
}
