import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/data/drift/drift_db.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/data/session/session_sql_statements.dart';
import 'package:app/models/session_models.dart';
import 'package:flutter/foundation.dart';

class DriftSessionRepository implements SessionRepository {
  DriftSessionRepository({required this.database, required this.selectedUser})
    : statements = SessionSqlStatements(database: database);

  final DriftDB database;
  final SessionSqlStatements statements;
  final SelectedUserController selectedUser;
  final ValueNotifier<List<Session>> _sessions = ValueNotifier<List<Session>>(
    const <Session>[],
  );

  @override
  ValueListenable<List<Session>> get sessionsListenable => _sessions;

  @override
  Future<Session?> getSession(String id) async {
    final userId = selectedUser.requiredUser.id;
    final row = await statements.getSession(userId: userId, sessionId: id);
    return row == null ? null : _toSession(row);
  }

  @override
  Future<List<Session>> listSessions() async {
    final userId = selectedUser.requiredUser.id;
    final rows = await statements.listSessions(userId: userId);
    final sessions = rows.map(_toSession).toList();
    if (!_sameSessions(_sessions.value, sessions)) {
      _sessions.value = List<Session>.unmodifiable(sessions);
    }
    return _sessions.value;
  }

  @override
  Future<void> saveSession(Session session) async {
    final userId = selectedUser.requiredUser.id;
    await saveSessionForUser(userId: userId, session: session);
    await listSessions();
  }

  @override
  Future<void> saveSessionForUser({
    required String userId,
    required Session session,
  }) async {
    await statements.saveSession(
      session: SessionRowsCompanion.insert(
        id: session.id,
        userId: userId,
        role: session.role.name,
        mode: session.mode.name,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }
}

Session _toSession(SessionRow row) {
  return Session(
    id: row.id,
    role: Role.values.byName(row.role),
    mode: Mode.values.byName(row.mode),
  );
}

bool _sameSessions(List<Session> left, List<Session> right) {
  if (left.length != right.length) {
    return false;
  }

  for (var index = 0; index < left.length; index += 1) {
    final leftSession = left[index];
    final rightSession = right[index];

    if (leftSession.id != rightSession.id ||
        leftSession.role != rightSession.role ||
        leftSession.mode != rightSession.mode) {
      return false;
    }
  }

  return true;
}
