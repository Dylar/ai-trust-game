import 'start_session_dto.dart';

class SessionApiClient {
  const SessionApiClient();

  Future<StartSessionResponse> startSession(StartSessionRequest request) async {
    // Keep a short artificial delay for now so the loading state remains visible
    // while this placeholder client stands in for the later real HTTP call.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final timestamp = DateTime.now().microsecondsSinceEpoch;

    return StartSessionResponse(
      sessionId: 'local-${request.role.name}-${request.mode.name}-$timestamp',
      role: request.role,
      mode: request.mode,
    );
  }
}
