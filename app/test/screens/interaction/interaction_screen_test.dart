import 'package:app/core/app/app_dependencies.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/models/interaction_models.dart';
import 'package:app/models/session_models.dart';
import 'package:app/screens/interaction/interaction_screen.dart';
import 'package:app/services/session_service.dart';
import 'package:flutter_test/flutter_test.dart';

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
    final dependencies = AppDependenciesData(
      interactionRepository: interactionRepository,
      sessionRepository: repository,
      sessionService: DefaultSessionService(
        apiClient: const SessionApiClient(),
        sessionRepository: repository,
      ),
    );

    // Given
    await context.appBot.startApp(
      home: const InteractionScreen(sessionId: 'local-admin-hard'),
      dependencies: dependencies,
    );

    // When
    context.screenBot.expectLoadingVisible();

    // Then
    await context.process.expectSessionDetailsLoaded('local-admin-hard');
    context.screenBot.expectInteractionVisible('request-1');
  });

  testWidgets('shows not found when the session is missing', (tester) async {
    final context = InteractionTestContext(tester);
    final interactionRepository = InMemoryInteractionRepository();
    final repository = InMemorySessionRepository();
    final dependencies = AppDependenciesData(
      interactionRepository: interactionRepository,
      sessionRepository: repository,
      sessionService: DefaultSessionService(
        apiClient: const SessionApiClient(),
        sessionRepository: repository,
      ),
    );

    // Given
    await context.appBot.startApp(
      home: const InteractionScreen(sessionId: 'missing-session'),
      dependencies: dependencies,
    );

    // When

    // Then
    await context.process.expectSessionNotFound();
  });
}
