import 'package:app/models/session_models.dart';

class StartSessionRequest {
  const StartSessionRequest({required this.role, required this.mode});

  final Role role;
  final Mode mode;

  Map<String, String> toJson() {
    return <String, String>{'role': role.name, 'mode': mode.name};
  }
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

  factory StartSessionResponse.fromJson(Map<String, dynamic> json) {
    return StartSessionResponse(
      sessionId: json['sessionId'] as String,
      role: Role.values.byName(json['role'] as String),
      mode: Mode.values.byName(json['mode'] as String),
    );
  }
}
