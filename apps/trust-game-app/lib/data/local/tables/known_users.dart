import 'package:drift/drift.dart';

class UserProfiles extends Table {
  @override
  String get tableName => 'users';

  TextColumn get id => text()();
  TextColumn get displayName => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastSelectedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
