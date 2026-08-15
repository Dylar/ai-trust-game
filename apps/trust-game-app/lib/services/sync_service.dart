import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/data/drift/drift_user_repository.dart';
import 'package:app/data/interaction/interaction_api_client.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/models/interaction_models.dart';
import 'package:app/services/sync_logger.dart';

enum SyncStatus { synced, failed }

class SyncResult {
  const SyncResult({required this.status});

  const SyncResult.synced() : status = SyncStatus.synced;

  const SyncResult.failed() : status = SyncStatus.failed;

  final SyncStatus status;

  bool get isSuccess => status == SyncStatus.synced;
}

class SyncService {
  SyncService({
    required AppLogger appLogger,
    required this.interactionApiClient,
    required this.interactionRepository,
    required this.userRepository,
    required this.sessionApiClient,
    required this.sessionRepository,
  }) : _logger = SyncLogger(appLogger: appLogger);

  final SyncLogger _logger;
  final InteractionApi interactionApiClient;
  final InteractionRepository interactionRepository;
  final UserRepository userRepository;
  final SessionApi sessionApiClient;
  final SessionRepository sessionRepository;

  Future<SyncResult> syncStartup() async {
    final users = await userRepository.listLoadedUsers();
    if (users.isEmpty) {
      return const SyncResult.synced();
    }

    for (final user in users) {
      final result = await syncUserRestore(user);
      if (!result.isSuccess) {
        return const SyncResult.failed();
      }
    }

    return const SyncResult.synced();
  }

  Future<SyncResult> syncUserRestore(UserProfile user) async {
    try {
      await _syncUserSessionsAndInteractions(user);
      return const SyncResult.synced();
    } on ApiException catch (error, stackTrace) {
      await _logger.logUserSyncFailed(
        user: user,
        status: SyncStatus.failed,
        error: error,
        stackTrace: stackTrace,
      );
      return const SyncResult.failed();
    }
  }

  Future<void> _syncUserSessionsAndInteractions(UserProfile user) async {
    final response = await sessionApiClient.listSessionsForUser(user.id);
    for (final session in response.sessions) {
      await sessionRepository.saveSessionForUser(
        userId: user.id,
        session: session,
      );
      final interactions = await interactionApiClient
          .listInteractionsForSession(userId: user.id, sessionId: session.id);
      for (final interaction in interactions.interactions) {
        await interactionRepository.saveInteractionForUser(
          userId: user.id,
          interaction: Interaction(
            sessionId: interaction.sessionId,
            interactionId: interaction.interactionId,
            message: interaction.message,
            answer: interaction.answer,
          ),
        );
      }
    }
  }
}
