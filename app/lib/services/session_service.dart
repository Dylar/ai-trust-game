import '../data/session/session_api_client.dart';
import '../data/session/session_repository.dart';
import '../models/start_session_models.dart';
import '../models/session_models.dart';

abstract interface class SessionService {
  Future<StartSessionResult> startSession(StartSessionRequest request);
}

class DefaultSessionService implements SessionService {
  const DefaultSessionService({
    required this.apiClient,
    required this.sessionRepository,
  });

  final SessionApiClient apiClient;
  final SessionRepository sessionRepository;

  @override
  Future<StartSessionResult> startSession(StartSessionRequest request) async {
    final result = await apiClient.startSession(request);

    await sessionRepository.saveSession(
      SessionSummary(
        id: result.sessionId,
        role: result.role,
        mode: result.mode,
        lastMessagePreview: _buildPlaceholderPreview(result),
      ),
    );

    return result;
  }

  String _buildPlaceholderPreview(StartSessionResult result) {
    return 'Placeholder ${result.role.name}/${result.mode.name} session ready.';
  }
}
