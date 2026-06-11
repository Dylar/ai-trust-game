import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/data/drift/drift_db.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/interaction/interaction_sql_statements.dart';
import 'package:app/models/interaction_models.dart';
import 'package:flutter/foundation.dart';

class DriftInteractionRepository implements InteractionRepository {
  DriftInteractionRepository({
    required this.database,
    required this.selectedUser,
  }) : statements = InteractionSqlStatements(database: database);

  final DriftDB database;
  final InteractionSqlStatements statements;
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
    final rows = await statements.listInteractions(
      userId: userId,
      sessionId: sessionId,
    );
    return rows.map(_toInteraction).toList();
  }

  @override
  Future<void> saveInteraction(Interaction interaction) async {
    final userId = selectedUser.requiredUser.id;
    await saveInteractionForUser(userId: userId, interaction: interaction);
    _changes.emitChange();
  }

  Future<void> saveInteractionForUser({
    required String userId,
    required Interaction interaction,
  }) async {
    await statements.saveInteraction(
      interaction: InteractionRowsCompanion.insert(
        interactionId: interaction.interactionId,
        sessionId: interaction.sessionId,
        userId: userId,
        message: interaction.message,
        answer: interaction.answer,
        savedAt: DateTime.now().toUtc(),
      ),
    );
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
