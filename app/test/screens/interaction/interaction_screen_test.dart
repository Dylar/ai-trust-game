import 'package:app/core/app/app_dependencies.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/models/session_models.dart';
import 'package:app/screens/interaction/interaction_screen.dart';
import 'package:app/services/session_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'interaction_test_context.dart';

void main() {
  testWidgets('shows session details for an existing session', (tester) async {
    final context = InteractionTestContext(tester);
    final repository = InMemorySessionRepository(
      initialSessions: const [
        SessionSummary(
          id: 'local-admin-hard',
          role: Role.admin,
          mode: Mode.hard,
          lastMessagePreview: 'Placeholder admin/hard session ready.',
        ),
      ],
    );
    final dependencies = AppDependenciesData(
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

    // Then
    context.process.expectSessionDetailsLoaded('local-admin-hard');
  });

  testWidgets('shows not found when the session is missing', (tester) async {
    final context = InteractionTestContext(tester);
    final repository = InMemorySessionRepository();
    final dependencies = AppDependenciesData(
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
    context.screenBot.expectScreenVisible();
    context.screenBot.expectNotFoundVisible();
  });
}
