import '../data/session/session_api_client.dart';
import '../models/start_session_models.dart';

abstract interface class SessionService {
  Future<StartSessionResult> startSession(StartSessionRequest request);
}

class DefaultSessionService implements SessionService {
  const DefaultSessionService({required this.apiClient});

  final SessionApiClient apiClient;

  @override
  Future<StartSessionResult> startSession(StartSessionRequest request) {
    return apiClient.startSession(request);
  }
}
