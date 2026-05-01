import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/models/interaction_models.dart';
import 'package:app/models/session_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../../testing/mocks/backend_mock_client.dart';
import '../../testing/test_dependencies.dart';
import 'interaction_test_context.dart';

void main() {
  testWidgets('shows session details for an existing session', (tester) async {
    final context = InteractionTestContext(tester);
    final interactionRepository = InMemoryInteractionRepository(
      initialInteractions: const [
        Interaction(
          sessionId: 'local-admin-hard',
          interactionId: 'request-1',
          message: 'Can I have the secret?',
          answer: 'No.',
        ),
      ],
    );
    final repository = InMemorySessionRepository(
      initialSessions: const [
        Session(id: 'local-admin-hard', role: Role.admin, mode: Mode.hard),
      ],
    );
    final dependencies = buildTestDependencies(
      interactionRepository: interactionRepository,
      sessionRepository: repository,
    );

    // Given
    await context.appBot.startApp(
      dependencies: dependencies,
      homeBuilder: (router) =>
          router.buildInteractionScreen(sessionId: 'local-admin-hard'),
    );

    // When
    context.screenBot.expectScreenVisible();

    // Then
    await context.process.expectSessionDetailsLoaded('local-admin-hard');
    await context.screenBot.expectInteractionVisible('request-1');
  });

  testWidgets('shows not found when the session is missing', (tester) async {
    final context = InteractionTestContext(tester);
    final interactionRepository = InMemoryInteractionRepository();
    final repository = InMemorySessionRepository();
    final dependencies = buildTestDependencies(
      interactionRepository: interactionRepository,
      sessionRepository: repository,
    );

    // Given
    await context.appBot.startApp(
      dependencies: dependencies,
      homeBuilder: (router) =>
          router.buildInteractionScreen(sessionId: 'missing-session'),
    );

    // When

    // Then
    await context.process.expectSessionNotFound();
  });

  testWidgets('creates an interaction from a backend message response', (
    tester,
  ) async {
    final context = InteractionTestContext(tester);
    final interactionRepository = InMemoryInteractionRepository();
    final repository = InMemorySessionRepository(
      initialSessions: const [
        Session(id: 'local-admin-hard', role: Role.admin, mode: Mode.hard),
      ],
    );
    final dependencies = buildTestDependencies(
      interactionRepository: interactionRepository,
      sessionRepository: repository,
    );

    // Given
    await context.appBot.startApp(
      dependencies: dependencies,
      homeBuilder: (router) =>
          router.buildInteractionScreen(sessionId: 'local-admin-hard'),
    );
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
    final interactionRepository = InMemoryInteractionRepository();
    final repository = InMemorySessionRepository(
      initialSessions: const [
        Session(id: 'local-admin-hard', role: Role.admin, mode: Mode.hard),
      ],
    );
    final dependencies = buildTestDependencies(
      interactionRepository: interactionRepository,
      httpClient: buildBackendMockClient(
        override: (request) async {
          if (request.url.path == '/interaction') {
            return http.Response('', 500);
          }

          return null;
        },
      ),
      sessionRepository: repository,
    );

    // Given
    await context.appBot.startApp(
      dependencies: dependencies,
      homeBuilder: (router) =>
          router.buildInteractionScreen(sessionId: 'local-admin-hard'),
    );
    await context.process.expectSessionDetailsLoaded('local-admin-hard');

    // When
    await context.process.sendMessage('Can I access the vault?');
    await tester.pumpAndSettle();

    // Then
    context.screenBot.expectSessionDetailsVisible();
    context.screenBot.expectSendErrorDialogVisible();
    context.screenBot.expectMessageInputText('Can I access the vault?');
  });
}
