import 'package:drift/drift.dart';

class InteractionRows extends Table {
  @override
  String get tableName => 'interactions';

  TextColumn get interactionId => text()();
  TextColumn get sessionId => text()();
  TextColumn get userId => text()();
  TextColumn get message => text()();
  TextColumn get answer => text()();
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {interactionId};
}
