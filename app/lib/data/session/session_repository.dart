import 'package:flutter/foundation.dart';

import '../../models/session_models.dart';

abstract interface class SessionRepository {
  ValueListenable<List<SessionSummary>> get recentSessionsListenable;

  Future<List<SessionSummary>> listRecentSessions();

  Future<SessionSummary?> getSession(String id);

  Future<void> saveSession(SessionSummary session);
}

class InMemorySessionRepository implements SessionRepository {
  InMemorySessionRepository({
    List<SessionSummary> initialSessions = const <SessionSummary>[],
  }) : _recentSessions = ValueNotifier<List<SessionSummary>>(
         List<SessionSummary>.unmodifiable(initialSessions),
       );

  final ValueNotifier<List<SessionSummary>> _recentSessions;

  @override
  ValueListenable<List<SessionSummary>> get recentSessionsListenable =>
      _recentSessions;

  @override
  Future<SessionSummary?> getSession(String id) async {
    for (final session in _recentSessions.value) {
      if (session.id == id) {
        return session;
      }
    }

    return null;
  }

  @override
  Future<List<SessionSummary>> listRecentSessions() async {
    return _recentSessions.value;
  }

  @override
  Future<void> saveSession(SessionSummary session) async {
    _recentSessions.value = List<SessionSummary>.unmodifiable([
      session,
      ..._recentSessions.value.where((item) => item.id != session.id),
    ]);
  }
}
