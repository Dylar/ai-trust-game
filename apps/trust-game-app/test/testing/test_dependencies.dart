import 'package:app/core/app/app_dependencies.dart';
import 'package:app/core/config/app_config.dart';
import 'package:app/core/config/app_flavor.dart';
import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/analysis/analysis_repository.dart';
import 'package:app/data/drift/drift_user_repository.dart';
import 'package:app/data/interaction/interaction_api_client.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/services/analysis_service.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/interaction_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/services/sync_service.dart';
import 'package:http/http.dart' as http;

import 'mocks/backend_mock_client.dart';
import 'test_user_profile.dart';

AppDependencies buildTestDependencies({
  AnalysisRepository? analysisRepository,
  AnalysisService? analysisService,
  AppLogger? appLogger,
  AuthService? authService,
  http.Client? httpClient,
  InteractionRepository? interactionRepository,
  InteractionService? interactionService,
  UserRepository? userRepository,
  SelectedUserController? selectedUser,
  SessionRepository? sessionRepository,
  SessionService? sessionService,
  SyncService? syncService,
}) {
  final config = AppConfig(
    apiBaseUri: Uri.parse('http://localhost:8080'),
    flavor: AppFlavor.test,
  );
  final resolvedHttpClient = httpClient ?? buildBackendMockClient();
  final resolvedSelectedUser =
      selectedUser ??
      SelectedUserController(initialUser: testUserProfile('test-user'));
  final resolvedAnalysisRepository =
      analysisRepository ?? InMemoryAnalysisRepository();
  final resolvedInteractionRepository =
      interactionRepository ?? InMemoryInteractionRepository();
  final resolvedSessionRepository =
      sessionRepository ?? InMemorySessionRepository();
  final resolvedUserRepository = userRepository ?? _EmptyUserRepository();
  final resolvedAppLogger = appLogger ?? const AppLogger(sinks: <AppLogSink>[]);

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
    appLogger: resolvedAppLogger,
    authService:
        authService ??
        AuthServiceImpl(
          appLogger: resolvedAppLogger,
          userRepository: resolvedUserRepository,
          selectedUser: resolvedSelectedUser,
        ),
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
    userRepository: resolvedUserRepository,
    selectedUser: resolvedSelectedUser,
    syncService: syncService ?? const _NoopSyncService(),
  );
}

class _EmptyUserRepository implements UserRepository {
  @override
  Future<List<UserProfile>> listLoadedUsers() async => const <UserProfile>[];

  @override
  Future<List<UserProfile>> listUnloadedUsers() async => const <UserProfile>[];

  @override
  Future<List<UserProfile>> listUsers() async => const <UserProfile>[];

  @override
  Future<void> saveUser(UserProfile user) async {}
}

class _NoopSyncService implements SyncService {
  const _NoopSyncService();

  @override
  Future<SyncResult> syncLoadedUsers() async {
    return const SyncResult(
      status: SyncStatus.noLoadedUsers,
      refreshedUserCount: 0,
      refreshedSessionCount: 0,
    );
  }

  @override
  Future<SyncResult> syncUser(UserProfile user) async {
    return const SyncResult(
      status: SyncStatus.refreshed,
      refreshedUserCount: 1,
      refreshedSessionCount: 0,
    );
  }
}
