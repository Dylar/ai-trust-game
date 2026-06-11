import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:app/data/analysis/tables/request_analyses.dart';
import 'package:app/data/analysis/tables/session_analyses.dart';
import 'package:app/data/interaction/tables/interactions.dart';
import 'package:app/data/local/tables/known_users.dart';
import 'package:app/data/local/tables/selected_users.dart';
import 'package:app/data/local/tables/sync_metadata.dart';
import 'package:app/data/session/tables/sessions.dart';

part 'local_database.g.dart';

@DriftDatabase(
  tables: [
    UserProfiles,
    SelectedUsers,
    SessionRows,
    InteractionRows,
    RequestAnalysisRows,
    SessionAnalysisRows,
    SyncMetadataEntries,
  ],
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase(super.executor);

  factory LocalDatabase.defaults() {
    return LocalDatabase(driftDatabase(name: 'ai_trust_game'));
  }

  @override
  int get schemaVersion => 1781190000;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
