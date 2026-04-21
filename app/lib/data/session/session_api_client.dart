import '../../models/start_session_models.dart';

class SessionApiClient {
  const SessionApiClient();

  Future<StartSessionResult> startSession(StartSessionRequest request) async {
    // Keep a short artificial delay for now so the loading state remains visible
    // while this placeholder client stands in for the later real HTTP call.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final timestamp = DateTime.now().microsecondsSinceEpoch;

    return StartSessionResult(
      sessionId: 'local-${request.role.name}-${request.mode.name}-$timestamp',
      role: request.role,
      mode: request.mode,
    );
  }
}
