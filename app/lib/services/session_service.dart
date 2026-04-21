import '../data/session/session_api_client.dart';
import '../data/session/session_repository.dart';
import '../data/session/start_session_dto.dart';
import '../models/session_models.dart';

abstract interface class SessionService {
  Future<SessionSummary> startSession({required Role role, required Mode mode});
}

class DefaultSessionService implements SessionService {
  const DefaultSessionService({
    required this.apiClient,
    required this.sessionRepository,
  });

  final SessionApiClient apiClient;
  final SessionRepository sessionRepository;

  @override
  Future<SessionSummary> startSession({
    required Role role,
    required Mode mode,
  }) async {
    final result = await apiClient.startSession(
      StartSessionRequest(role: role, mode: mode),
    );

    final session = SessionSummary(
      id: result.sessionId,
      role: result.role,
      mode: result.mode,
      lastMessagePreview: _buildPlaceholderPreview(result),
    );

    await sessionRepository.saveSession(session);

    return session;
  }

  String _buildPlaceholderPreview(StartSessionResponse result) {
    return 'Placeholder ${result.role.name}/${result.mode.name} session ready.';
  }
}
