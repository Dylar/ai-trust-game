import 'package:app/screens/interaction/interaction_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/base_screen_bot.dart';

class InteractionScreenBot extends BaseScreenBot {
  InteractionScreenBot(super.tester);

  void expectScreenVisible() {
    expect(isVisible(InteractionKeys.screen), isTrue);
    expect(isVisible(InteractionKeys.title), isTrue);
  }

  void expectLoadingVisible() {
    expect(isVisible(InteractionKeys.loadingState), isTrue);
  }

  void expectSessionDetailsVisible() {
    expect(isVisible(InteractionKeys.sessionDetailsSection), isTrue);
    expect(isVisible(InteractionKeys.sessionIdItem), isTrue);
    expect(isVisible(InteractionKeys.roleItem), isTrue);
    expect(isVisible(InteractionKeys.modeItem), isTrue);
  }

  Future<void> expectInteractionsSectionVisible() async {
    await scrollUntilVisible(InteractionKeys.interactionsSection);
    expect(isVisible(InteractionKeys.interactionsSection), isTrue);
  }

  Future<void> enterMessage(String message) async {
    await enterText(InteractionKeys.composerMessageInput, message);
  }

  Future<void> tapSendMessage() async {
    await tap(InteractionKeys.composerSendButton);
  }

  void expectSendButtonEnabled() {
    final button = tester.widget<FilledButton>(
      find.byKey(InteractionKeys.composerSendButton),
    );
    expect(button.onPressed, isNotNull);
  }

  void expectMessageInputText(String message) {
    expect(
      tester
          .widget<TextField>(find.byKey(InteractionKeys.composerMessageInput))
          .controller
          ?.text,
      message,
    );
  }

  Future<void> expectEmptyInteractionsVisible() async {
    await scrollUntilVisible(InteractionKeys.emptyInteractionsState);
    expect(isVisible(InteractionKeys.emptyInteractionsState), isTrue);
  }

  Future<void> expectInteractionVisible(String interactionId) async {
    await scrollUntilVisible(InteractionKeys.interaction(interactionId));
    expect(isVisible(InteractionKeys.interaction(interactionId)), isTrue);
  }

  void expectNotFoundVisible() {
    expect(isVisible(InteractionKeys.notFoundState), isTrue);
  }

  void expectSessionIdShown(String sessionId) {
    expect(find.textContaining(sessionId, findRichText: true), findsOneWidget);
  }

  Future<void> expectInteractionMessageShown(String message) async {
    await scrollUntilVisible(find.text(message));
    expect(find.text(message), findsOneWidget);
  }

  Future<void> expectPlaceholderAnswerShown(String message) async {
    await scrollUntilVisible(find.text('Backend answer for: "$message"'));
    expect(find.text('Backend answer for: "$message"'), findsOneWidget);
  }

  void expectSendErrorDialogVisible() {
    expect(find.text('Message could not be sent'), findsOneWidget);
  }
}
