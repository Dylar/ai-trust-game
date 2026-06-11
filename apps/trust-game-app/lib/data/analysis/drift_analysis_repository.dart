import 'dart:convert';

import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/data/analysis/analysis_repository.dart';
import 'package:app/data/analysis/analysis_sql_statements.dart';
import 'package:app/data/drift/drift_db.dart';
import 'package:app/models/analysis_models.dart';

class DriftAnalysisRepository implements AnalysisRepository {
  DriftAnalysisRepository({required this.database, required this.selectedUser})
    : statements = AnalysisSqlStatements(database: database);

  final DriftDB database;
  final AnalysisSqlStatements statements;
  final SelectedUserController selectedUser;

  @override
  Future<RequestAnalysis?> getRequestAnalysis(String requestId) async {
    final userId = selectedUser.requiredUser.id;
    final row = await statements.getRequestAnalysis(
      userId: userId,
      requestId: requestId,
    );
    return row == null ? null : _toRequestAnalysis(row);
  }

  @override
  Future<SessionAnalysis?> getSessionAnalysis(String sessionId) async {
    final userId = selectedUser.requiredUser.id;
    final sessionRow = await statements.getSessionAnalysis(
      userId: userId,
      sessionId: sessionId,
    );
    if (sessionRow == null) {
      return null;
    }

    final requestRows = await statements.listRequestAnalysesForSession(
      userId: userId,
      sessionId: sessionId,
    );
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
    await saveRequestAnalysisForUser(
      userId: selectedUser.requiredUser.id,
      analysis: analysis,
    );
  }

  Future<void> saveRequestAnalysisForUser({
    required String userId,
    required RequestAnalysis analysis,
  }) async {
    await statements.saveRequestAnalysis(
      analysis: _requestAnalysisCompanion(userId: userId, analysis: analysis),
    );
  }

  @override
  Future<void> saveSessionAnalysis(SessionAnalysis analysis) async {
    await saveSessionAnalysisForUser(
      userId: selectedUser.requiredUser.id,
      analysis: analysis,
    );
  }

  Future<void> saveSessionAnalysisForUser({
    required String userId,
    required SessionAnalysis analysis,
  }) async {
    await statements.saveSessionAnalysis(
      session: SessionAnalysisRowsCompanion.insert(
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
      requests: analysis.requests
          .map((request) {
            return _requestAnalysisCompanion(userId: userId, analysis: request);
          })
          .toList(growable: false),
    );
  }
}

RequestAnalysisRowsCompanion _requestAnalysisCompanion({
  required String userId,
  required RequestAnalysis analysis,
}) {
  return RequestAnalysisRowsCompanion.insert(
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
  );
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
