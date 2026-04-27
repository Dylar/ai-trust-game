import 'package:flutter/foundation.dart';

import 'package:app/models/interaction_models.dart';

abstract interface class InteractionRepository {
  Listenable get changes;

  Future<Interaction?> getLastInteraction(String sessionId);

  Future<List<Interaction>> listInteractions(String sessionId);

  Future<void> saveInteraction(Interaction interaction);
}

class InMemoryInteractionRepository implements InteractionRepository {
  InMemoryInteractionRepository({
    List<Interaction> initialInteractions = const <Interaction>[],
  }) : _interactionsBySession = ValueNotifier<Map<String, List<Interaction>>>(
         _groupBySession(initialInteractions),
       );

  final ValueNotifier<Map<String, List<Interaction>>> _interactionsBySession;

  @override
  Listenable get changes => _interactionsBySession;

  @override
  Future<Interaction?> getLastInteraction(String sessionId) async {
    final interactions = _interactionsBySession.value[sessionId];
    if (interactions == null || interactions.isEmpty) {
      return null;
    }

    return interactions.last;
  }

  @override
  Future<List<Interaction>> listInteractions(String sessionId) async {
    return _interactionsBySession.value[sessionId] ?? const <Interaction>[];
  }

  @override
  Future<void> saveInteraction(Interaction interaction) async {
    final nextBySession = Map<String, List<Interaction>>.of(
      _interactionsBySession.value,
    );
    final existing =
        nextBySession[interaction.sessionId] ?? const <Interaction>[];
    final updated = List<Interaction>.unmodifiable([
      ...existing.where(
        (item) => item.interactionId != interaction.interactionId,
      ),
      interaction,
    ]);

    nextBySession[interaction.sessionId] = updated;
    _interactionsBySession.value = Map<String, List<Interaction>>.unmodifiable(
      nextBySession,
    );
  }

  static Map<String, List<Interaction>> _groupBySession(
    List<Interaction> interactions,
  ) {
    final grouped = <String, List<Interaction>>{};

    for (final interaction in interactions) {
      final items = grouped.putIfAbsent(
        interaction.sessionId,
        () => <Interaction>[],
      );
      items.removeWhere(
        (item) => item.interactionId == interaction.interactionId,
      );
      items.add(interaction);
    }

    return Map<String, List<Interaction>>.unmodifiable({
      for (final entry in grouped.entries)
        entry.key: List<Interaction>.unmodifiable(entry.value),
    });
  }
}
