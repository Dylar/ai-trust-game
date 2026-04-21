import 'package:flutter/material.dart';

abstract final class InteractionKeys {
  static const screen = Key('interaction.screen');
  static const title = Key('interaction.title');
  static const loadingState = Key('interaction.loading_state');
  static const sessionDetailsSection = Key(
    'interaction.session_details_section',
  );
  static const notFoundState = Key('interaction.not_found_state');
  static const interactionsSection = Key('interaction.interactions_section');
  static const emptyInteractionsState = Key(
    'interaction.empty_interactions_state',
  );

  static const sessionIdItem = Key('interaction.item.session_id');
  static const roleItem = Key('interaction.item.role');
  static const modeItem = Key('interaction.item.mode');

  static Key interaction(String interactionId) {
    return ValueKey<String>('interaction.item.$interactionId');
  }
}
