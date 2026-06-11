import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';

import 'package:app/data/local/local_database.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/models/session_models.dart';

class DriftSessionRepository implements SessionRepository {
  DriftSessionRepository({required this.database, required this.userId});

  final LocalDatabase database;
  final String userId;
  final ValueNotifier<List<Session>> _sessions = ValueNotifier<List<Session>>(
    const <Session>[],
  );

  @override
  ValueListenable<List<Session>> get sessionsListenable => _sessions;

  @override
  Future<Session?> getSession(String id) async {
    final row =
        await (database.select(database.sessionRows)
              ..where((tbl) => tbl.id.equals(id) & tbl.userId.equals(userId)))
            .getSingleOrNull();
    return row == null ? null : _toSession(row);
  }

  @override
  Future<List<Session>> listSessions() async {
    final rows =
        await (database.select(database.sessionRows)
              ..where((tbl) => tbl.userId.equals(userId))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
            .get();
    final sessions = rows.map(_toSession).toList();
    _sessions.value = List<Session>.unmodifiable(sessions);
    return _sessions.value;
  }

  @override
  Future<void> saveSession(Session session) async {
    await database
        .into(database.sessionRows)
        .insertOnConflictUpdate(
          SessionRowsCompanion.insert(
            id: session.id,
            userId: userId,
            role: session.role.name,
            mode: session.mode.name,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    await listSessions();
  }
}

Session _toSession(SessionRow row) {
  return Session(
    id: row.id,
    role: Role.values.byName(row.role),
    mode: Mode.values.byName(row.mode),
  );
}
