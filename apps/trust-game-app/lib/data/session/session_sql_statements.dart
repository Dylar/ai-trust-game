import 'package:app/data/drift/drift_db.dart';
import 'package:drift/drift.dart';

class SessionSqlStatements {
  const SessionSqlStatements({required this.database});

  final DriftDB database;

  Future<SessionRow?> getSession({
    required String userId,
    required String sessionId,
  }) {
    return (database.select(
          database.sessionRows,
        )..where((tbl) => tbl.id.equals(sessionId) & tbl.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<List<SessionRow>> listSessions({required String userId}) {
    return (database.select(database.sessionRows)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
        .get();
  }

  Future<void> saveSession({required SessionRowsCompanion session}) {
    return database.into(database.sessionRows).insertOnConflictUpdate(session);
  }
}
