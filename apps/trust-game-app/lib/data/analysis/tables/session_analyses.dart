import 'package:drift/drift.dart';

class SessionAnalysisRows extends Table {
  @override
  String get tableName => 'session_analyses';

  TextColumn get sessionId => text()();
  TextColumn get userId => text()();
  TextColumn get classification => text()();
  TextColumn get signalsJson => text()();
  TextColumn get attackPatternsJson => text()();
  TextColumn get intentSummary => text()();
  IntColumn get requestCount => integer()();
  IntColumn get suspicionCount => integer()();
  IntColumn get modelFailCount => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId};
}
