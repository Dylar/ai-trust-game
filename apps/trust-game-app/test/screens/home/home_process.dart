import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/data/drift/drift_db.dart';
import 'package:app/data/interaction/drift_interaction_repository.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/drift_session_repository.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/models/interaction_models.dart';
import 'package:app/models/session_models.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/app_process.dart';
import '../../testing/test_dependencies.dart';
import '../../testing/test_user_profile.dart';
import '../session_start/session_start_process.dart';
import 'home_screen_bot.dart';

class HomeProcess {
  HomeProcess({
    required this.appProcess,
    required this.screenBot,
    required this.sessionStartProcess,
    required this.tester,
  });

  final AppProcess appProcess;
  final HomeScreenBot screenBot;
  final SessionStartProcess sessionStartProcess;
  final WidgetTester tester;

  Future<void> startHome() async {
    await appProcess.startHome();
  }

  Future<void> startHomeWithSessions({
    required List<Session> sessions,
    List<Interaction> interactions = const <Interaction>[],
  }) async {
    await appProcess.startHome(
      dependencies: buildTestDependencies(
        interactionRepository: InMemoryInteractionRepository(
          initialInteractions: interactions,
        ),
        sessionRepository: InMemorySessionRepository(initialSessions: sessions),
      ),
    );
  }

  Future<void> startHomeWithRestoredDriftSession({
    required Session session,
    required Interaction interaction,
    String userId = 'user-1',
  }) async {
    final database = DriftDB.forTest(migrations: [InitialDriftMigration()]);
    final selectedUser = SelectedUserController(
      initialUser: testUserProfile(userId),
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      selectedUser.dispose();
      await database.close();
    });
    final sessionRepository = DriftSessionRepository(
      database: database,
      selectedUser: selectedUser,
    );
    final interactionRepository = DriftInteractionRepository(
      database: database,
      selectedUser: selectedUser,
    );
    await sessionRepository.saveSession(session);
    await interactionRepository.saveInteraction(interaction);

    await appProcess.startHome(
      dependencies: buildTestDependencies(
        interactionRepository: interactionRepository,
        selectedUser: selectedUser,
        sessionRepository: sessionRepository,
      ),
    );
  }

  Future<void> openSessionStart() async {
    await screenBot.tapStartSession();
    await screenBot.pump(const Duration(milliseconds: 300));
  }

  Future<void> waitUntilRecentSessionsLoaded() async {
    await screenBot.pump(const Duration(milliseconds: 1));
  }

  Future<void> createAdminHardSessionFromHome() async {
    await openSessionStart();
    await sessionStartProcess.prepareAdminHardSession();
    await screenBot.pump(const Duration(milliseconds: 300));
  }

  Future<void> openFirstRecentSession() async {
    await screenBot.tapFirstRecentSession();
    await screenBot.pump(const Duration(milliseconds: 300));
  }

  void expectRecentSessionPreviewVisible(String previewMessage) {
    screenBot.expectRecentSessionPreviewVisible(previewMessage);
  }
}
