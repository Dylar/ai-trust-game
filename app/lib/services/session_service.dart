import '../data/session/session_api_client.dart';
import '../data/session/session_repository.dart';
import '../data/session/start_session_dto.dart';
import '../models/session_models.dart';

abstract interface class SessionService {
  Future<Session> startSession({required Role role, required Mode mode});
}

class SessionServiceImpl implements SessionService {
  const SessionServiceImpl({
    required this.apiClient,
    required this.sessionRepository,
  });

  final SessionApiClient apiClient;
  final SessionRepository sessionRepository;

  @override
  Future<Session> startSession({required Role role, required Mode mode}) async {
    final result = await apiClient.startSession(
      StartSessionRequest(role: role, mode: mode),
    );

    final session = Session(
      id: result.sessionId,
      role: result.role,
      mode: result.mode,
    );

    await sessionRepository.saveSession(session);

    return session;
  }
}
