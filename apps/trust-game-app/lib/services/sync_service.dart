import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/analysis/drift_analysis_repository.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/data/drift/drift_user_repository.dart';
import 'package:app/data/interaction/drift_interaction_repository.dart';
import 'package:app/data/interaction/interaction_api_client.dart';
import 'package:app/data/session/drift_session_repository.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/models/interaction_models.dart';
import 'package:app/services/sync_logger.dart';

enum SyncStatus { noLoadedUsers, refreshed, offlineFallback, partialFailure }

class SyncResult {
  const SyncResult({
    required this.status,
    required this.refreshedUserCount,
    required this.refreshedSessionCount,
    this.failedUserIds = const <String>[],
  });

  final SyncStatus status;
  final int refreshedUserCount;
  final int refreshedSessionCount;
  final List<String> failedUserIds;
}

abstract interface class SyncService {
  Future<SyncResult> syncLoadedUsers();

  Future<SyncResult> syncUser(UserProfile user);
}

class SyncServiceImpl implements SyncService {
  SyncServiceImpl({
    required AppLogger appLogger,
    required this.analysisApiClient,
    required this.analysisRepository,
    required this.interactionApiClient,
    required this.interactionRepository,
    required this.userRepository,
    required this.sessionApiClient,
    required this.sessionRepository,
  }) : _logger = SyncLogger(appLogger: appLogger);

  final SyncLogger _logger;
  final AnalysisApiClient analysisApiClient;
  final DriftAnalysisRepository analysisRepository;
  final InteractionApiClient interactionApiClient;
  final DriftInteractionRepository interactionRepository;
  final UserRepository userRepository;
  final SessionApiClient sessionApiClient;
  final DriftSessionRepository sessionRepository;

  @override
  Future<SyncResult> syncLoadedUsers() async {
    final users = await userRepository.listLoadedUsers();
    if (users.isEmpty) {
      return const SyncResult(
        status: SyncStatus.noLoadedUsers,
        refreshedUserCount: 0,
        refreshedSessionCount: 0,
      );
    }

    var refreshedSessionCount = 0;
    final failedUserIds = <String>[];
    var sawOfflineFailure = false;
    var refreshedUserCount = 0;

    for (final user in users) {
      final result = await syncUser(user);
      if (result.status == SyncStatus.refreshed) {
        refreshedUserCount += 1;
      }
      refreshedSessionCount += result.refreshedSessionCount;
      if (result.status == SyncStatus.offlineFallback ||
          result.status == SyncStatus.partialFailure) {
        failedUserIds.add(user.id);
        sawOfflineFailure =
            sawOfflineFailure || result.status == SyncStatus.offlineFallback;
      }
    }

    if (refreshedUserCount == 0 && sawOfflineFailure) {
      return SyncResult(
        status: SyncStatus.offlineFallback,
        refreshedUserCount: refreshedUserCount,
        refreshedSessionCount: refreshedSessionCount,
        failedUserIds: List<String>.unmodifiable(failedUserIds),
      );
    }

    return SyncResult(
      status: failedUserIds.isEmpty
          ? SyncStatus.refreshed
          : SyncStatus.partialFailure,
      refreshedUserCount: refreshedUserCount,
      refreshedSessionCount: refreshedSessionCount,
      failedUserIds: List<String>.unmodifiable(failedUserIds),
    );
  }

  @override
  Future<SyncResult> syncUser(UserProfile user) async {
    try {
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
        await _refreshAnalysisForSession(
          userId: user.id,
          sessionId: session.id,
          requestIds: interactions.interactions
              .map((interaction) => interaction.interactionId)
              .toList(growable: false),
        );
      }

      return SyncResult(
        status: SyncStatus.refreshed,
        refreshedUserCount: 1,
        refreshedSessionCount: response.sessions.length,
      );
    } on ApiException catch (error, stackTrace) {
      final status = error.code == ApiErrorCode.backendUnreachable
          ? SyncStatus.offlineFallback
          : SyncStatus.partialFailure;
      await _logger.logUserSyncFailed(
        user: user,
        status: status,
        error: error,
        stackTrace: stackTrace,
      );
      return SyncResult(
        status: status,
        refreshedUserCount: 0,
        refreshedSessionCount: 0,
        failedUserIds: <String>[user.id],
      );
    }
  }

  Future<void> _refreshAnalysisForSession({
    required String userId,
    required String sessionId,
    required List<String> requestIds,
  }) async {
    await _ignoreMissingAnalysis(() async {
      final response = await analysisApiClient.getSessionAnalysisForUser(
        userId: userId,
        sessionId: sessionId,
      );
      await analysisRepository.saveSessionAnalysisForUser(
        userId: userId,
        analysis: response.analysis,
      );
    });

    for (final requestId in requestIds) {
      await _ignoreMissingAnalysis(() async {
        final response = await analysisApiClient.getRequestAnalysisForUser(
          userId: userId,
          requestId: requestId,
        );
        await analysisRepository.saveRequestAnalysisForUser(
          userId: userId,
          analysis: response.analysis,
        );
      });
    }
  }

  Future<void> _ignoreMissingAnalysis(Future<void> Function() load) async {
    try {
      await load();
    } on ApiException catch (error) {
      if (error.code == ApiErrorCode.sessionAnalysisNotFound ||
          error.code == ApiErrorCode.requestAnalysisNotFound) {
        return;
      }
      rethrow;
    }
  }
}
