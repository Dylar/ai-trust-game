import 'package:app/data/analysis/tables/request_analyses.dart';
import 'package:app/data/analysis/tables/session_analyses.dart';
import 'package:app/data/drift/tables/users.dart';
import 'package:app/data/interaction/tables/interactions.dart';
import 'package:app/data/session/tables/sessions.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'drift_db.g.dart';

const aiTrustGameDriftDatabaseName = 'aiTrustGameDriftDB';

class DBVersion {
  const DBVersion(this.version, this.name);

  final int version;
  final String name;
}

abstract class DriftMigration {
  Future<void> onUpgrade(
    DriftDB db,
    Migrator migrator,
    int oldVersion,
    int newVersion,
  );
}

class InitialDriftMigration extends DriftMigration {
  static const initialVersion = DBVersion(1781197120, 'Initial');

  @override
  Future<void> onUpgrade(
    DriftDB db,
    Migrator migrator,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < initialVersion.version) {
      await migrator.createAll();
    }
  }
}

@DriftDatabase(
  tables: [
    UserRows,
    SessionRows,
    InteractionRows,
    RequestAnalysisRows,
    SessionAnalysisRows,
  ],
)
class DriftDB extends _$DriftDB {
  factory DriftDB.defaults() {
    return DriftDB(migrations: [InitialDriftMigration()]);
  }

  DriftDB({required this.migrations})
    : super(driftDatabase(name: aiTrustGameDriftDatabaseName));

  DriftDB.forTest({required this.migrations}) : super(NativeDatabase.memory());

  final List<DriftMigration> migrations;

  static const versions = <DBVersion>[InitialDriftMigration.initialVersion];

  static Future<DriftDB> open() async {
    return openWith(migrations: [InitialDriftMigration()]);
  }

  static Future<DriftDB> openWith({
    List<DriftMigration> migrations = const [],
  }) async {
    return DriftDB(migrations: migrations);
  }

  @override
  int get schemaVersion => versions.last.version;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
      },
      onUpgrade: (migrator, oldVersion, newVersion) async {
        for (final migration in migrations) {
          await migration.onUpgrade(this, migrator, oldVersion, newVersion);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
