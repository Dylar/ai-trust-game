import 'package:app/models/interaction_models.dart';
import 'package:app/models/session_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'interaction_test_context.dart';

void main() {
  testWidgets('shows session details for an existing session', (tester) async {
    final context = InteractionTestContext(tester);
    const session = Session(
      id: 'local-admin-hard',
      role: Role.admin,
      mode: Mode.hard,
    );

    // Given
    await context.process.startWithSession(
      session: session,
      interactions: const [
        Interaction(
          sessionId: 'local-admin-hard',
          interactionId: 'request-1',
          message: 'Can I have the secret?',
          answer: 'No.',
        ),
      ],
    );

    // When
    context.screenBot.expectScreenVisible();

    // Then
    await context.process.expectSessionDetailsLoaded('local-admin-hard');
    await context.screenBot.expectInteractionVisible('request-1');
  });

  testWidgets('shows restored local interactions from Drift persistence', (
    tester,
  ) async {
    final context = InteractionTestContext(tester);
    const session = Session(
      id: 'restored-session',
      role: Role.employee,
      mode: Mode.medium,
    );
    const interaction = Interaction(
      sessionId: 'restored-session',
      interactionId: 'request-1',
      message: 'Restored local message',
      answer: 'Restored local answer',
    );

    // Given
    await context.process.startWithRestoredDriftSession(
      session: session,
      interaction: interaction,
    );

    // Then
    await context.process.expectSessionDetailsLoaded('restored-session');
    await context.screenBot.expectInteractionVisible('request-1');
    await context.screenBot.expectInteractionMessageShown(
      'Restored local message',
    );
  });

  testWidgets('shows not found when the session is missing', (tester) async {
    final context = InteractionTestContext(tester);

    // Given
    await context.process.startWithMissingSession('missing-session');

    // When

    // Then
    await context.process.expectSessionNotFound();
  });

  testWidgets('opens an error dialog when session loading fails', (
    tester,
  ) async {
    final context = InteractionTestContext(tester);

    // Given
    await context.process.startWithFailingSessionLoad('local-admin-hard');

    // Then
    await context.process.expectSessionLoadError();
  });

  testWidgets('creates an interaction from a backend message response', (
    tester,
  ) async {
    final context = InteractionTestContext(tester);
    const session = Session(
      id: 'local-admin-hard',
      role: Role.admin,
      mode: Mode.hard,
    );

    // Given
    await context.process.startWithSession(session: session);
    await context.process.expectSessionDetailsLoaded('local-admin-hard');
    await context.screenBot.expectEmptyInteractionsVisible();

    // When
    await context.process.sendMessage('Can I access the vault?');

    // Then
    await context.process.expectInteractionCreated('Can I access the vault?');
  });

  testWidgets('keeps the failed message visible when sending fails', (
    tester,
  ) async {
    final context = InteractionTestContext(tester);
    const session = Session(
      id: 'local-admin-hard',
      role: Role.admin,
      mode: Mode.hard,
    );

    // Given
    await context.process.startWithInteractionFailure(
      session: session,
      statusCode: 500,
    );
    await context.process.expectSessionDetailsLoaded('local-admin-hard');

    // When
    await context.process.sendMessageExpectingFailure(
      'Can I access the vault?',
    );

    // Then
    context.screenBot.expectSessionDetailsVisible();
    context.screenBot.expectSendErrorDialogVisible();
    context.screenBot.expectMessageInputText('Can I access the vault?');
  });

  testWidgets('keeps the failed message visible when sending offline', (
    tester,
  ) async {
    final context = InteractionTestContext(tester);
    const session = Session(
      id: 'local-admin-hard',
      role: Role.admin,
      mode: Mode.hard,
    );

    // Given
    await context.process.startWithOfflineInteraction(session: session);
    await context.process.expectSessionDetailsLoaded('local-admin-hard');

    // When
    await context.process.sendMessageExpectingFailure(
      'Can I access the vault?',
    );

    // Then
    context.screenBot.expectSessionDetailsVisible();
    context.screenBot.expectSendErrorDialogVisible();
    context.screenBot.expectMessageInputText('Can I access the vault?');
  });
}
