import 'package:app/core/app/app_dependencies.dart';
import 'package:app/core/config/app_config.dart';
import 'package:app/core/config/app_flavor.dart';
import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/core/user/user_identity.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/analysis/analysis_repository.dart';
import 'package:app/data/interaction/interaction_api_client.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/local/local_user_repository.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/services/analysis_service.dart';
import 'package:app/services/interaction_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/services/startup_refresh_service.dart';
import 'package:http/http.dart' as http;

import 'mocks/backend_mock_client.dart';

AppDependencies buildTestDependencies({
  AnalysisRepository? analysisRepository,
  AnalysisService? analysisService,
  AppLogger? appLogger,
  http.Client? httpClient,
  InteractionRepository? interactionRepository,
  InteractionService? interactionService,
  LocalUserRepository? localUserRepository,
  SelectedUserController? selectedUser,
  SessionRepository? sessionRepository,
  SessionService? sessionService,
  StartupRefreshService? startupRefreshService,
}) {
  final config = AppConfig(
    apiBaseUri: Uri.parse('http://localhost:8080'),
    flavor: AppFlavor.test,
  );
  final resolvedHttpClient = httpClient ?? buildBackendMockClient();
  final resolvedSelectedUser =
      selectedUser ??
      SelectedUserController(initialUser: const UserIdentity(id: 'test-user'));
  final resolvedAnalysisRepository =
      analysisRepository ?? InMemoryAnalysisRepository();
  final resolvedInteractionRepository =
      interactionRepository ?? InMemoryInteractionRepository();
  final resolvedSessionRepository =
      sessionRepository ?? InMemorySessionRepository();

  return AppDependencies(
    analysisService:
        analysisService ??
        AnalysisServiceImpl(
          analysisRepository: resolvedAnalysisRepository,
          apiClient: AnalysisApiClient(
            httpClient: resolvedHttpClient,
            apiBaseUri: config.apiBaseUri,
            selectedUser: resolvedSelectedUser,
          ),
        ),
    appLogger: appLogger ?? const AppLogger(sinks: <AppLogSink>[]),
    config: config,
    httpClient: resolvedHttpClient,
    interactionRepository: resolvedInteractionRepository,
    interactionService:
        interactionService ??
        InteractionServiceImpl(
          apiClient: InteractionApiClient(
            httpClient: resolvedHttpClient,
            apiBaseUri: config.apiBaseUri,
            selectedUser: resolvedSelectedUser,
          ),
          interactionRepository: resolvedInteractionRepository,
        ),
    sessionRepository: resolvedSessionRepository,
    sessionService:
        sessionService ??
        SessionServiceImpl(
          apiClient: SessionApiClient(
            httpClient: resolvedHttpClient,
            apiBaseUri: config.apiBaseUri,
            selectedUser: resolvedSelectedUser,
          ),
          sessionRepository: resolvedSessionRepository,
        ),
    localUserRepository: localUserRepository ?? _EmptyLocalUserRepository(),
    selectedUser: resolvedSelectedUser,
    startupRefreshService:
        startupRefreshService ?? const _NoopStartupRefreshService(),
  );
}

class _EmptyLocalUserRepository implements LocalUserRepository {
  @override
  Future<KnownUser?> getSelectedUser() async => null;

  @override
  Future<List<KnownUser>> listLoadedUsers() async => const <KnownUser>[];

  @override
  Future<List<KnownUser>> listUnloadedUsers() async => const <KnownUser>[];

  @override
  Future<List<KnownUser>> listUsers() async => const <KnownUser>[];

  @override
  Future<void> saveKnownUser(KnownUser user) async {}

  @override
  Future<void> selectUser(String userId) async {}
}

class _NoopStartupRefreshService implements StartupRefreshService {
  const _NoopStartupRefreshService();

  @override
  Future<StartupRefreshResult> refreshKnownUsers() async {
    return const StartupRefreshResult(
      status: StartupRefreshStatus.noKnownUsers,
      refreshedUserCount: 0,
      refreshedSessionCount: 0,
    );
  }
}
