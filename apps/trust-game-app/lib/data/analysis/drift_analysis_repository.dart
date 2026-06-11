import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:app/data/analysis/analysis_repository.dart';
import 'package:app/data/local/local_database.dart';
import 'package:app/models/analysis_models.dart';

class DriftAnalysisRepository implements AnalysisRepository {
  const DriftAnalysisRepository({required this.database, required this.userId});

  final LocalDatabase database;
  final String userId;

  @override
  Future<RequestAnalysis?> getRequestAnalysis(String requestId) async {
    final row =
        await (database.select(database.requestAnalysisRows)..where(
              (tbl) =>
                  tbl.requestId.equals(requestId) & tbl.userId.equals(userId),
            ))
            .getSingleOrNull();
    return row == null ? null : _toRequestAnalysis(row);
  }

  @override
  Future<SessionAnalysis?> getSessionAnalysis(String sessionId) async {
    final sessionRow =
        await (database.select(database.sessionAnalysisRows)..where(
              (tbl) =>
                  tbl.sessionId.equals(sessionId) & tbl.userId.equals(userId),
            ))
            .getSingleOrNull();
    if (sessionRow == null) {
      return null;
    }

    final requestRows =
        await (database.select(database.requestAnalysisRows)..where(
              (tbl) =>
                  tbl.sessionId.equals(sessionId) & tbl.userId.equals(userId),
            ))
            .get();
    final requests = requestRows.map(_toRequestAnalysis).toList()
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    return SessionAnalysis(
      sessionId: sessionRow.sessionId,
      classification: sessionRow.classification,
      signals: _decodeStringList(sessionRow.signalsJson),
      attackPatterns: _decodeStringList(sessionRow.attackPatternsJson),
      intentSummary: sessionRow.intentSummary,
      requestCount: sessionRow.requestCount,
      requests: requests,
      suspicionCount: sessionRow.suspicionCount,
      modelFailCount: sessionRow.modelFailCount,
    );
  }

  @override
  Future<void> saveRequestAnalysis(RequestAnalysis analysis) async {
    await database
        .into(database.requestAnalysisRows)
        .insertOnConflictUpdate(
          RequestAnalysisRowsCompanion.insert(
            requestId: analysis.requestId,
            sessionId: analysis.sessionId,
            userId: userId,
            completedAt: analysis.completedAt,
            classification: analysis.classification,
            signalsJson: _encodeStringList(analysis.signals),
            attackPatternsJson: _encodeStringList(analysis.attackPatterns),
            intentSummary: analysis.intentSummary,
            eventCount: analysis.eventCount,
            suspicionCount: analysis.suspicionCount,
            modelFailCount: analysis.modelFailCount,
          ),
        );
  }

  @override
  Future<void> saveSessionAnalysis(SessionAnalysis analysis) async {
    await database.transaction(() async {
      await database
          .into(database.sessionAnalysisRows)
          .insertOnConflictUpdate(
            SessionAnalysisRowsCompanion.insert(
              sessionId: analysis.sessionId,
              userId: userId,
              classification: analysis.classification,
              signalsJson: _encodeStringList(analysis.signals),
              attackPatternsJson: _encodeStringList(analysis.attackPatterns),
              intentSummary: analysis.intentSummary,
              requestCount: analysis.requestCount,
              suspicionCount: analysis.suspicionCount,
              modelFailCount: analysis.modelFailCount,
              updatedAt: DateTime.now().toUtc(),
            ),
          );

      for (final request in analysis.requests) {
        await saveRequestAnalysis(request);
      }
    });
  }
}

RequestAnalysis _toRequestAnalysis(RequestAnalysisRow row) {
  return RequestAnalysis(
    requestId: row.requestId,
    sessionId: row.sessionId,
    completedAt: row.completedAt,
    classification: row.classification,
    signals: _decodeStringList(row.signalsJson),
    attackPatterns: _decodeStringList(row.attackPatternsJson),
    intentSummary: row.intentSummary,
    eventCount: row.eventCount,
    suspicionCount: row.suspicionCount,
    modelFailCount: row.modelFailCount,
  );
}

String _encodeStringList(List<String> values) {
  return jsonEncode(values);
}

List<String> _decodeStringList(String value) {
  final decoded = jsonDecode(value) as List<dynamic>;
  return decoded.cast<String>();
}
