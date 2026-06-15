import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/models/interaction_models.dart';
import 'package:app/models/session_models.dart';
import 'package:flutter/foundation.dart';
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

  testWidgets('opens an error dialog when session loading fails', (
    tester,
  ) async {
    final context = InteractionTestContext(tester);
    final dependencies = buildTestDependencies(
      sessionRepository: _FailingSessionRepository(),
    );

    // Given
    await context.appBot.startApp(
      dependencies: dependencies,
      homeBuilder: (router) =>
          router.buildInteractionScreen(sessionId: 'local-admin-hard'),
    );
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Interaction could not be loaded'), findsOneWidget);
    expect(
      find.text(
        'The session could not be loaded. Please go back and try again.',
      ),
      findsWidgets,
    );
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

class _FailingSessionRepository implements SessionRepository {
  final ValueNotifier<List<Session>> _sessions = ValueNotifier<List<Session>>(
    const <Session>[],
  );

  @override
  ValueListenable<List<Session>> get sessionsListenable => _sessions;

  @override
  Future<Session?> getSession(String id) async {
    throw Exception('load failed');
  }

  @override
  Future<List<Session>> listSessions() async {
    return const <Session>[];
  }

  @override
  Future<void> saveSession(Session session) async {}
}
