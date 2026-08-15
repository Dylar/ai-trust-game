import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/data/session/start_session_dto.dart';
import 'package:app/models/session_models.dart';

class SessionService {
  const SessionService({
    required this.apiClient,
    required this.sessionRepository,
  });

  final SessionApi apiClient;
  final SessionRepository sessionRepository;

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
