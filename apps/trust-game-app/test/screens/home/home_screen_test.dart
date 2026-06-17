import 'package:app/models/interaction_models.dart';
import 'package:app/models/session_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'home_test_context.dart';

void main() {
  testWidgets('shows the home screen with a start action and an empty list', (
    tester,
  ) async {
    final context = HomeTestContext(tester);

    // Given
    await context.process.startHome();

    // When

    // Then
    context.screenBot.expectScreenVisible();
    context.screenBot.expectStartSessionVisible();
    context.screenBot.expectEmptySessionsVisible();
  });

  testWidgets('navigates from home to session start', (tester) async {
    final context = HomeTestContext(tester);

    // Given
    await context.process.startHome();

    // When
    await context.process.openSessionStart();

    // Then
    context.sessionStartBot.expectScreenVisible();
  });

  testWidgets('navigates from session start to interaction', (tester) async {
    final context = HomeTestContext(tester);

    // Given
    await context.process.startHome();

    // When
    await context.process.createAdminHardSessionFromHome();

    // Then
    context.interactionScreenBot.expectScreenVisible();
    context.interactionScreenBot.expectSessionDetailsVisible();
  });

  testWidgets('opens interaction from a recent home session', (tester) async {
    final context = HomeTestContext(tester);
    const session = Session(
      id: 'seeded-session',
      role: Role.employee,
      mode: Mode.medium,
    );

    // Given
    await context.process.startHomeWithSessions(
      sessions: const <Session>[session],
    );
    await context.process.waitUntilRecentSessionsLoaded();
    context.screenBot.expectRecentSessionCount(1);

    // When
    await context.process.openFirstRecentSession();

    // Then
    context.interactionScreenBot.expectScreenVisible();
    context.interactionScreenBot.expectSessionDetailsVisible();
  });

  testWidgets('shows the last interaction message in recent sessions', (
    tester,
  ) async {
    final context = HomeTestContext(tester);
    const session = Session(
      id: 'seeded-session',
      role: Role.employee,
      mode: Mode.medium,
    );

    await context.process.startHomeWithSessions(
      sessions: const <Session>[session],
      interactions: const [
        Interaction(
          sessionId: 'seeded-session',
          interactionId: 'request-1',
          message: 'Latest preview message',
          answer: 'Backend answer',
        ),
      ],
    );
    await context.process.waitUntilRecentSessionsLoaded();

    context.screenBot.expectRecentSessionVisible('seeded-session');
    context.process.expectRecentSessionPreviewVisible('Latest preview message');
  });

  testWidgets('shows restored local session preview from Drift persistence', (
    tester,
  ) async {
    final context = HomeTestContext(tester);
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

    await context.process.startHomeWithRestoredDriftSession(
      session: session,
      interaction: interaction,
    );
    await context.process.waitUntilRecentSessionsLoaded();

    context.screenBot.expectRecentSessionVisible('restored-session');
    context.process.expectRecentSessionPreviewVisible('Restored local message');
  });
}
