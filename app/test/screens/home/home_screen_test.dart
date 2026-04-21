import 'package:app/core/app/app_dependencies.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/models/session_models.dart';
import 'package:app/services/session_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'home_test_context.dart';

void main() {
  testWidgets('shows the home screen with a start action and an empty list', (
    tester,
  ) async {
    final context = HomeTestContext(tester);

    // Given
    await context.appBot.startApp();

    // When

    // Then
    context.screenBot.expectScreenVisible();
    context.screenBot.expectStartSessionVisible();
    context.screenBot.expectEmptySessionsVisible();
  });

  testWidgets('navigates from home to session start', (tester) async {
    final context = HomeTestContext(tester);

    // Given
    await context.appBot.startApp();

    // When
    await context.process.openSessionStart();

    // Then
    context.sessionStartBot.expectScreenVisible();
  });

  testWidgets('navigates from session start to interaction', (tester) async {
    final context = HomeTestContext(tester);

    // Given
    await context.appBot.startApp();

    // When
    await context.process.createAdminHardSessionFromHome();

    // Then
    context.interactionScreenBot.expectScreenVisible();
    context.interactionScreenBot.expectSessionDetailsVisible();
  });

  testWidgets('opens interaction from a recent home session', (tester) async {
    final context = HomeTestContext(tester);
    final repository = InMemorySessionRepository(
      initialSessions: const [
        Session(id: 'seeded-session', role: Role.employee, mode: Mode.medium),
      ],
    );
    final dependencies = AppDependenciesData(
      interactionRepository: InMemoryInteractionRepository(),
      sessionRepository: repository,
      sessionService: DefaultSessionService(
        apiClient: const SessionApiClient(),
        sessionRepository: repository,
      ),
    );

    // Given
    await context.appBot.startApp(dependencies: dependencies);
    await context.process.waitUntilRecentSessionsLoaded();
    context.screenBot.expectRecentSessionCount(1);

    // When
    await context.process.openFirstRecentSession();

    // Then
    context.interactionScreenBot.expectScreenVisible();
    context.interactionScreenBot.expectSessionDetailsVisible();
  });
}
