import 'package:app/core/app/app_dependencies.dart';
import 'package:app/core/config/app_config.dart';
import 'package:app/core/config/app_flavor.dart';
import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/core/user/user_profile.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/analysis/analysis_repository.dart';
import 'package:app/data/auth/auth_api_client.dart';
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
  AnalysisApi? analysisApi,
  AnalysisRepository? analysisRepository,
  AppLogger? appLogger,
  AuthApi? authApi,
  http.Client? httpClient,
  InteractionApi? interactionApi,
  InteractionRepository? interactionRepository,
  SessionApi? sessionApi,
  UserRepository? userRepository,
  SelectedUserController? selectedUser,
  SessionRepository? sessionRepository,
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
  final analysisApiClient =
      analysisApi ??
      AnalysisApiClient(
        httpClient: resolvedHttpClient,
        apiBaseUri: config.apiBaseUri,
        selectedUser: resolvedSelectedUser,
      );
  final authApiClient =
      authApi ??
      AuthApiClient(
        httpClient: resolvedHttpClient,
        apiBaseUri: config.apiBaseUri,
      );
  final interactionApiClient =
      interactionApi ??
      InteractionApiClient(
        httpClient: resolvedHttpClient,
        apiBaseUri: config.apiBaseUri,
        selectedUser: resolvedSelectedUser,
      );
  final sessionApiClient =
      sessionApi ??
      SessionApiClient(
        httpClient: resolvedHttpClient,
        apiBaseUri: config.apiBaseUri,
        selectedUser: resolvedSelectedUser,
      );

  return AppDependencies(
    analysisService: AnalysisService(
      analysisRepository: resolvedAnalysisRepository,
      apiClient: analysisApiClient,
    ),
    appLogger: resolvedAppLogger,
    authService: AuthService(
      appLogger: resolvedAppLogger,
      userRepository: resolvedUserRepository,
      selectedUser: resolvedSelectedUser,
      apiClient: authApiClient,
    ),
    config: config,
    httpClient: resolvedHttpClient,
    interactionRepository: resolvedInteractionRepository,
    interactionService: InteractionService(
      apiClient: interactionApiClient,
      interactionRepository: resolvedInteractionRepository,
    ),
    sessionRepository: resolvedSessionRepository,
    sessionService: SessionService(
      apiClient: sessionApiClient,
      sessionRepository: resolvedSessionRepository,
    ),
    userRepository: resolvedUserRepository,
    selectedUser: resolvedSelectedUser,
    syncService: SyncService(
      appLogger: resolvedAppLogger,
      interactionApiClient: interactionApiClient,
      interactionRepository: resolvedInteractionRepository,
      userRepository: resolvedUserRepository,
      sessionApiClient: sessionApiClient,
      sessionRepository: resolvedSessionRepository,
    ),
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
