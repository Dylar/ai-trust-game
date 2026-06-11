import 'package:app/data/drift/drift_db.dart';
import 'package:drift/drift.dart';

class InteractionSqlStatements {
  const InteractionSqlStatements({required this.database});

  final DriftDB database;

  Future<List<InteractionRow>> listInteractions({
    required String userId,
    required String sessionId,
  }) {
    return (database.select(database.interactionRows)
          ..where(
            (tbl) =>
                tbl.sessionId.equals(sessionId) & tbl.userId.equals(userId),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.savedAt)]))
        .get();
  }

  Future<void> saveInteraction({
    required InteractionRowsCompanion interaction,
  }) {
    return database
        .into(database.interactionRows)
        .insertOnConflictUpdate(interaction);
  }
}
