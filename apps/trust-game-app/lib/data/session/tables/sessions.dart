import 'package:drift/drift.dart';

class SessionRows extends Table {
  @override
  String get tableName => 'sessions';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get role => text()();
  TextColumn get mode => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
