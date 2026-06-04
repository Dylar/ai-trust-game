import 'package:flutter/foundation.dart';

import 'package:app/models/session_models.dart';

abstract interface class SessionRepository {
  ValueListenable<List<Session>> get sessionsListenable;

  Future<List<Session>> listSessions();

  Future<Session?> getSession(String id);

  Future<void> saveSession(Session session);
}

class InMemorySessionRepository implements SessionRepository {
  InMemorySessionRepository({List<Session> initialSessions = const <Session>[]})
    : _sessions = ValueNotifier<List<Session>>(
        List<Session>.unmodifiable(initialSessions),
      );

  final ValueNotifier<List<Session>> _sessions;

  @override
  ValueListenable<List<Session>> get sessionsListenable => _sessions;

  @override
  Future<Session?> getSession(String id) async {
    for (final session in _sessions.value) {
      if (session.id == id) {
        return session;
      }
    }

    return null;
  }

  @override
  Future<List<Session>> listSessions() async {
    return _sessions.value;
  }

  @override
  Future<void> saveSession(Session session) async {
    _sessions.value = List<Session>.unmodifiable([
      session,
      ..._sessions.value.where((item) => item.id != session.id),
    ]);
  }
}
