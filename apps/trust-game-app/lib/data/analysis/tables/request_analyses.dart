import 'package:drift/drift.dart';

class RequestAnalysisRows extends Table {
  @override
  String get tableName => 'request_analyses';

  TextColumn get requestId => text()();
  TextColumn get sessionId => text()();
  TextColumn get userId => text()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get classification => text()();
  TextColumn get signalsJson => text()();
  TextColumn get attackPatternsJson => text()();
  TextColumn get intentSummary => text()();
  IntColumn get eventCount => integer()();
  IntColumn get suspicionCount => integer()();
  IntColumn get modelFailCount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {requestId};
}
