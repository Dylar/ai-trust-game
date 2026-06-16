import 'package:app/core/config/app_config.dart';
import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/logging/local_app_log_sink.dart';
import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/analysis/drift_analysis_repository.dart';
import 'package:app/data/auth/auth_api_client.dart';
import 'package:app/data/drift/drift_db.dart';
import 'package:app/data/drift/drift_user_repository.dart';
import 'package:app/data/interaction/drift_interaction_repository.dart';
import 'package:app/data/interaction/interaction_api_client.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/logging/backend_app_log_sink.dart';
import 'package:app/data/logging/log_api_client.dart';
import 'package:app/data/session/drift_session_repository.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/services/analysis_service.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/interaction_service.dart';
import 'package:app/services/session_service.dart';
import 'package:app/services/sync_service.dart';
import 'package:http/http.dart' as http;

class AppDependencies {
  const AppDependencies({
    required this.analysisService,
    required this.appLogger,
    required this.authService,
    required this.config,
    required this.httpClient,
    required this.interactionRepository,
    required this.interactionService,
    this.driftDB,
    required this.userRepository,
    required this.selectedUser,
    required this.sessionRepository,
    required this.sessionService,
    required this.syncService,
  });

  factory AppDependencies.defaults({
    SelectedUserController? selectedUser,
    AppConfig? config,
    http.Client? httpClient,
    DriftDB? driftDB,
  }) {
    final resolvedConfig = config ?? AppConfig.fromEnvironment();
    final resolvedHttpClient = httpClient ?? http.Client();
    final resolvedDriftDB = driftDB ?? DriftDB.defaults();
    final resolvedSelectedUser = selectedUser ?? SelectedUserController();
    final userRepository = DriftUserRepository(database: resolvedDriftDB);
    final authApiClient = AuthApiClient(
      httpClient: resolvedHttpClient,
      apiBaseUri: resolvedConfig.apiBaseUri,
    );
    final analysisRepository = DriftAnalysisRepository(
      database: resolvedDriftDB,
      selectedUser: resolvedSelectedUser,
    );
    final interactionRepository = DriftInteractionRepository(
      database: resolvedDriftDB,
      selectedUser: resolvedSelectedUser,
    );
    final logApiClient = LogApiClient(
      httpClient: resolvedHttpClient,
      apiBaseUri: resolvedConfig.apiBaseUri,
      selectedUser: resolvedSelectedUser,
    );
    final appLogger = AppLogger(
      sinks: <AppLogSink>[
        const LocalAppLogSink(),
        BackendAppLogSink(apiClient: logApiClient),
      ],
    );
    final sessionRepository = DriftSessionRepository(
      database: resolvedDriftDB,
      selectedUser: resolvedSelectedUser,
    );
    final sessionApiClient = SessionApiClient(
      httpClient: resolvedHttpClient,
      apiBaseUri: resolvedConfig.apiBaseUri,
      selectedUser: resolvedSelectedUser,
    );
    final analysisApiClient = AnalysisApiClient(
      httpClient: resolvedHttpClient,
      apiBaseUri: resolvedConfig.apiBaseUri,
      selectedUser: resolvedSelectedUser,
    );
    final interactionApiClient = InteractionApiClient(
      httpClient: resolvedHttpClient,
      apiBaseUri: resolvedConfig.apiBaseUri,
      selectedUser: resolvedSelectedUser,
    );

    return AppDependencies(
      analysisService: AnalysisServiceImpl(
        analysisRepository: analysisRepository,
        apiClient: analysisApiClient,
      ),
      appLogger: appLogger,
      authService: AuthServiceImpl(
        appLogger: appLogger,
        userRepository: userRepository,
        selectedUser: resolvedSelectedUser,
        apiClient: authApiClient,
      ),
      config: resolvedConfig,
      httpClient: resolvedHttpClient,
      interactionRepository: interactionRepository,
      interactionService: InteractionServiceImpl(
        interactionRepository: interactionRepository,
        apiClient: interactionApiClient,
      ),
      driftDB: resolvedDriftDB,
      userRepository: userRepository,
      selectedUser: resolvedSelectedUser,
      sessionRepository: sessionRepository,
      sessionService: SessionServiceImpl(
        sessionRepository: sessionRepository,
        apiClient: sessionApiClient,
      ),
      syncService: SyncServiceImpl(
        appLogger: appLogger,
        interactionApiClient: interactionApiClient,
        interactionRepository: interactionRepository,
        userRepository: userRepository,
        sessionApiClient: sessionApiClient,
        sessionRepository: sessionRepository,
      ),
    );
  }

  final AnalysisService analysisService;
  final AppLogger appLogger;
  final AuthService authService;
  final AppConfig config;
  final http.Client httpClient;
  final InteractionRepository interactionRepository;
  final InteractionService interactionService;
  final DriftDB? driftDB;
  final UserRepository userRepository;
  final SelectedUserController selectedUser;
  final SessionRepository sessionRepository;
  final SessionService sessionService;
  final SyncService syncService;
}
