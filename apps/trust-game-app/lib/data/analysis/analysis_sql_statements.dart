import 'package:app/data/drift/drift_db.dart';
import 'package:drift/drift.dart';

class AnalysisSqlStatements {
  const AnalysisSqlStatements({required this.database});

  final DriftDB database;

  Future<RequestAnalysisRow?> getRequestAnalysis({
    required String userId,
    required String requestId,
  }) {
    return (database.select(database.requestAnalysisRows)..where(
          (tbl) => tbl.requestId.equals(requestId) & tbl.userId.equals(userId),
        ))
        .getSingleOrNull();
  }

  Future<SessionAnalysisRow?> getSessionAnalysis({
    required String userId,
    required String sessionId,
  }) {
    return (database.select(database.sessionAnalysisRows)..where(
          (tbl) => tbl.sessionId.equals(sessionId) & tbl.userId.equals(userId),
        ))
        .getSingleOrNull();
  }

  Future<List<RequestAnalysisRow>> listRequestAnalysesForSession({
    required String userId,
    required String sessionId,
  }) {
    return (database.select(database.requestAnalysisRows)..where(
          (tbl) => tbl.sessionId.equals(sessionId) & tbl.userId.equals(userId),
        ))
        .get();
  }

  Future<void> saveRequestAnalysis({
    required RequestAnalysisRowsCompanion analysis,
  }) {
    return database
        .into(database.requestAnalysisRows)
        .insertOnConflictUpdate(analysis);
  }

  Future<void> saveSessionAnalysis({
    required SessionAnalysisRowsCompanion session,
    required List<RequestAnalysisRowsCompanion> requests,
  }) {
    return database.transaction(() async {
      await database
          .into(database.sessionAnalysisRows)
          .insertOnConflictUpdate(session);

      for (final request in requests) {
        await saveRequestAnalysis(analysis: request);
      }
    });
  }
}
