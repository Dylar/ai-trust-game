import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/data/drift/drift_db.dart';
import 'package:app/data/interaction/drift_interaction_repository.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/drift_session_repository.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/models/interaction_models.dart';
import 'package:app/models/session_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/app_process.dart';
import '../../testing/test_dependencies.dart';
import '../../testing/test_user_profile.dart';
import '../interaction/interaction_fakes.dart';
import '../interaction/interaction_screen_bot.dart';

class InteractionProcess {
  InteractionProcess({required this.appProcess, required this.screenBot});

  final AppProcess appProcess;
  final InteractionScreenBot screenBot;

  Future<void> startWithSession({
    required Session session,
    List<Interaction> interactions = const <Interaction>[],
  }) async {
    await appProcess.startInteraction(
      sessionId: session.id,
      dependencies: buildTestDependencies(
        interactionRepository: InMemoryInteractionRepository(
          initialInteractions: interactions,
        ),
        sessionRepository: InMemorySessionRepository(
          initialSessions: <Session>[session],
        ),
      ),
    );
  }

  Future<void> startWithRestoredDriftSession({
    required Session session,
    required Interaction interaction,
    String userId = 'user-1',
  }) async {
    final database = DriftDB.forTest(migrations: [InitialDriftMigration()]);
    final selectedUser = SelectedUserController(
      initialUser: testUserProfile(userId),
    );
    addTearDown(() async {
      selectedUser.dispose();
      await database.close();
    });
    final interactionRepository = DriftInteractionRepository(
      database: database,
      selectedUser: selectedUser,
    );
    final sessionRepository = DriftSessionRepository(
      database: database,
      selectedUser: selectedUser,
    );
    await sessionRepository.saveSession(session);
    await interactionRepository.saveInteraction(interaction);

    await appProcess.startInteraction(
      sessionId: session.id,
      dependencies: buildTestDependencies(
        interactionRepository: interactionRepository,
        selectedUser: selectedUser,
        sessionRepository: sessionRepository,
      ),
    );
  }

  Future<void> startWithMissingSession(String sessionId) async {
    await appProcess.startInteraction(
      sessionId: sessionId,
      dependencies: buildTestDependencies(
        interactionRepository: InMemoryInteractionRepository(),
        sessionRepository: InMemorySessionRepository(),
      ),
    );
  }

  Future<void> startWithFailingSessionLoad(String sessionId) async {
    await appProcess.startInteraction(
      sessionId: sessionId,
      dependencies: buildTestDependencies(
        sessionRepository: FailingSessionRepository(),
      ),
    );
  }

  Future<void> startWithInteractionFailure({
    required Session session,
    required int statusCode,
  }) async {
    await appProcess.startInteraction(
      sessionId: session.id,
      dependencies: buildTestDependencies(
        interactionRepository: InMemoryInteractionRepository(),
        httpClient: interactionFailureClient(statusCode: statusCode),
        sessionRepository: InMemorySessionRepository(
          initialSessions: <Session>[session],
        ),
      ),
    );
  }

  Future<void> startWithOfflineInteraction({required Session session}) async {
    await appProcess.startInteraction(
      sessionId: session.id,
      dependencies: buildTestDependencies(
        interactionRepository: InMemoryInteractionRepository(),
        httpClient: offlineInteractionClient(),
        sessionRepository: InMemorySessionRepository(
          initialSessions: <Session>[session],
        ),
      ),
    );
  }

  Future<void> waitUntilSessionLoaded() async {
    await screenBot.pump(const Duration(milliseconds: 1));
  }

  Future<void> expectSessionDetailsLoaded(String sessionId) async {
    await waitUntilSessionLoaded();
    screenBot.expectScreenVisible();
    screenBot.expectSessionDetailsVisible();
    screenBot.expectSessionIdShown(sessionId);
  }

  Future<void> sendMessage(String message) async {
    await screenBot.enterMessage(message);
    screenBot.expectSendButtonEnabled();
    await screenBot.tapSendMessage();
    await screenBot.pump(const Duration(milliseconds: 1));
  }

  Future<void> sendMessageExpectingFailure(String message) async {
    await sendMessage(message);
    await screenBot.pumpAndSettle();
  }

  Future<void> expectInteractionCreated(String message) async {
    await screenBot.expectInteractionMessageShown(message);
    await screenBot.expectPlaceholderAnswerShown(message);
  }

  Future<void> expectSessionNotFound() async {
    await waitUntilSessionLoaded();
    screenBot.expectScreenVisible();
    screenBot.expectNotFoundVisible();
  }

  Future<void> expectSessionLoadError() async {
    await screenBot.pumpAndSettle();
    screenBot.expectLoadErrorDialogVisible();
  }
}
