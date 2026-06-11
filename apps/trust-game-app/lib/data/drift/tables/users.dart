import 'package:drift/drift.dart';

class UserRows extends Table {
  @override
  String get tableName => 'users';

  TextColumn get id => text()();
  TextColumn get displayName => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
