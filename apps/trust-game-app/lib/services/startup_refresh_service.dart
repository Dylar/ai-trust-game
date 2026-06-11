import 'package:app/data/api/api_error.dart';
import 'package:app/data/local/local_user_repository.dart';
import 'package:app/data/session/drift_session_repository.dart';
import 'package:app/data/session/session_api_client.dart';

enum StartupRefreshStatus {
  noKnownUsers,
  refreshed,
  offlineFallback,
  partialFailure,
}

class StartupRefreshResult {
  const StartupRefreshResult({
    required this.status,
    required this.refreshedUserCount,
    required this.refreshedSessionCount,
    this.failedUserIds = const <String>[],
  });

  final StartupRefreshStatus status;
  final int refreshedUserCount;
  final int refreshedSessionCount;
  final List<String> failedUserIds;
}

abstract interface class StartupRefreshService {
  Future<StartupRefreshResult> refreshKnownUsers();
}

class StartupRefreshServiceImpl implements StartupRefreshService {
  const StartupRefreshServiceImpl({
    required this.localUserRepository,
    required this.sessionApiClient,
    required this.sessionRepository,
  });

  final LocalUserRepository localUserRepository;
  final SessionApiClient sessionApiClient;
  final DriftSessionRepository sessionRepository;

  @override
  Future<StartupRefreshResult> refreshKnownUsers() async {
    final users = await localUserRepository.listUsers();
    if (users.isEmpty) {
      return const StartupRefreshResult(
        status: StartupRefreshStatus.noKnownUsers,
        refreshedUserCount: 0,
        refreshedSessionCount: 0,
      );
    }

    var refreshedUserCount = 0;
    var refreshedSessionCount = 0;
    final failedUserIds = <String>[];
    var sawOfflineFailure = false;

    for (final user in users) {
      try {
        final response = await sessionApiClient.listSessionsForUser(user.id);
        for (final session in response.sessions) {
          await sessionRepository.saveSessionForUser(
            userId: user.id,
            session: session,
          );
        }
        refreshedUserCount += 1;
        refreshedSessionCount += response.sessions.length;
      } on SessionApiException catch (error) {
        failedUserIds.add(user.id);
        sawOfflineFailure =
            sawOfflineFailure || error.code == ApiErrorCode.backendUnreachable;
      }
    }

    if (refreshedUserCount == 0 && sawOfflineFailure) {
      return StartupRefreshResult(
        status: StartupRefreshStatus.offlineFallback,
        refreshedUserCount: refreshedUserCount,
        refreshedSessionCount: refreshedSessionCount,
        failedUserIds: List<String>.unmodifiable(failedUserIds),
      );
    }

    return StartupRefreshResult(
      status: failedUserIds.isEmpty
          ? StartupRefreshStatus.refreshed
          : StartupRefreshStatus.partialFailure,
      refreshedUserCount: refreshedUserCount,
      refreshedSessionCount: refreshedSessionCount,
      failedUserIds: List<String>.unmodifiable(failedUserIds),
    );
  }
}
