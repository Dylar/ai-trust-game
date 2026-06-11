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

class ListSessionsResponse {
  const ListSessionsResponse({required this.sessions});

  final List<Session> sessions;

  factory ListSessionsResponse.fromJson(Map<String, dynamic> json) {
    final sessionsJson = json['sessions'] as List<dynamic>? ?? <dynamic>[];
    return ListSessionsResponse(
      sessions: sessionsJson
          .map((item) => _sessionFromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

Session _sessionFromJson(Map<String, dynamic> json) {
  return Session(
    id: json['sessionId'] as String,
    role: Role.values.byName(json['role'] as String),
    mode: Mode.values.byName(json['mode'] as String),
  );
}
