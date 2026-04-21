import 'package:flutter/foundation.dart';

import '../../models/interaction_models.dart';

abstract interface class InteractionRepository {
  ValueListenable<List<Interaction>> get interactionsListenable;

  Future<List<Interaction>> listInteractions(String sessionId);

  Future<void> saveInteraction(Interaction interaction);
}

class InMemoryInteractionRepository implements InteractionRepository {
  InMemoryInteractionRepository({
    List<Interaction> initialInteractions = const <Interaction>[],
  }) : _interactions = ValueNotifier<List<Interaction>>(
         List<Interaction>.unmodifiable(initialInteractions),
       );

  final ValueNotifier<List<Interaction>> _interactions;

  @override
  ValueListenable<List<Interaction>> get interactionsListenable =>
      _interactions;

  @override
  Future<List<Interaction>> listInteractions(String sessionId) async {
    return _interactions.value
        .where((interaction) => interaction.sessionId == sessionId)
        .toList(growable: false);
  }

  @override
  Future<void> saveInteraction(Interaction interaction) async {
    _interactions.value = List<Interaction>.unmodifiable([
      ..._interactions.value.where(
        (item) => item.interactionId != interaction.interactionId,
      ),
      interaction,
    ]);
  }
}
