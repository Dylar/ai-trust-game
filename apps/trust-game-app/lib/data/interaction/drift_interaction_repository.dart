import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';

import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/local/local_database.dart';
import 'package:app/models/interaction_models.dart';

class DriftInteractionRepository implements InteractionRepository {
  DriftInteractionRepository({
    required this.database,
    required this.selectedUser,
  });

  final LocalDatabase database;
  final SelectedUserController selectedUser;
  final _RepositoryChangeNotifier _changes = _RepositoryChangeNotifier();

  @override
  Listenable get changes => _changes;

  @override
  Future<Interaction?> getLastInteraction(String sessionId) async {
    final rows = await listInteractions(sessionId);
    return rows.isEmpty ? null : rows.last;
  }

  @override
  Future<List<Interaction>> listInteractions(String sessionId) async {
    final userId = selectedUser.requiredUser.id;
    final rows =
        await (database.select(database.interactionRows)
              ..where(
                (tbl) =>
                    tbl.sessionId.equals(sessionId) & tbl.userId.equals(userId),
              )
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.savedAt)]))
            .get();
    return rows.map(_toInteraction).toList();
  }

  @override
  Future<void> saveInteraction(Interaction interaction) async {
    final userId = selectedUser.requiredUser.id;
    await database
        .into(database.interactionRows)
        .insertOnConflictUpdate(
          InteractionRowsCompanion.insert(
            interactionId: interaction.interactionId,
            sessionId: interaction.sessionId,
            userId: userId,
            message: interaction.message,
            answer: interaction.answer,
            savedAt: DateTime.now().toUtc(),
          ),
        );
    _changes.emitChange();
  }
}

class _RepositoryChangeNotifier extends ChangeNotifier {
  void emitChange() {
    notifyListeners();
  }
}

Interaction _toInteraction(InteractionRow row) {
  return Interaction(
    sessionId: row.sessionId,
    interactionId: row.interactionId,
    message: row.message,
    answer: row.answer,
  );
}
