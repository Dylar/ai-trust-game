import '../../models/session_models.dart';

class StartSessionRequest {
  const StartSessionRequest({required this.role, required this.mode});

  final Role role;
  final Mode mode;
}

class StartSessionResponse {
  const StartSessionResponse({
    required this.sessionId,
    required this.role,
    required this.mode,
  });

  final String sessionId;
  final Role role;
  final Mode mode;
}
