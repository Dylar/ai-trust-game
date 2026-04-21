import 'session_models.dart';

class StartSessionRequest {
  const StartSessionRequest({required this.role, required this.mode});

  final Role role;
  final Mode mode;
}

class StartSessionResult {
  const StartSessionResult({
    required this.sessionId,
    required this.role,
    required this.mode,
  });

  final String sessionId;
  final Role role;
  final Mode mode;
}
