import 'package:drift/drift.dart';

import 'known_users.dart';

class SelectedUsers extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get userId => text().references(UserProfiles, #id)();
  DateTimeColumn get selectedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
