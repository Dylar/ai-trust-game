import 'package:flutter/material.dart';

abstract final class InteractionKeys {
  static const screen = Key('interaction.screen');
  static const title = Key('interaction.title');
  static const sessionDetailsSection = Key(
    'interaction.session_details_section',
  );
  static const notFoundState = Key('interaction.not_found_state');

  static const sessionIdItem = Key('interaction.item.session_id');
  static const roleItem = Key('interaction.item.role');
  static const modeItem = Key('interaction.item.mode');
  static const previewItem = Key('interaction.item.preview');
}
