import 'package:app/core/config/app_config.dart';
import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/logging/local_app_log_sink.dart';
import 'package:app/core/user/user_identity.dart';
import 'package:app/data/analysis/drift_analysis_repository.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/interaction/drift_interaction_repository.dart';
import 'package:app/data/interaction/interaction_api_client.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/local/local_database.dart';
import 'package:app/data/logging/backend_app_log_sink.dart';
import 'package:app/data/logging/log_api_client.dart';
import 'package:app/data/session/drift_session_repository.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/services/analysis_service.dart';
import 'package:app/services/interaction_service.dart';
import 'package:app/services/session_service.dart';
import 'package:http/http.dart' as http;

class AppDependencies {
  const AppDependencies({
    required this.analysisService,
    required this.appLogger,
    required this.config,
    required this.httpClient,
    required this.interactionRepository,
    required this.interactionService,
    this.localDatabase,
    required this.sessionRepository,
    required this.sessionService,
    required this.userIdentity,
  });

  factory AppDependencies.forUser({
    required UserIdentity userIdentity,
    AppConfig? config,
    http.Client? httpClient,
    LocalDatabase? localDatabase,
  }) {
    final resolvedConfig = config ?? AppConfig.fromEnvironment();
    final resolvedHttpClient = httpClient ?? http.Client();
    final resolvedLocalDatabase = localDatabase ?? LocalDatabase.defaults();
    final analysisRepository = DriftAnalysisRepository(
      database: resolvedLocalDatabase,
      userId: userIdentity.id,
    );
    final interactionRepository = DriftInteractionRepository(
      database: resolvedLocalDatabase,
      userId: userIdentity.id,
    );
    final logApiClient = LogApiClient(
      httpClient: resolvedHttpClient,
      apiBaseUri: resolvedConfig.apiBaseUri,
      userId: userIdentity.id,
    );
    final appLogger = AppLogger(
      sinks: <AppLogSink>[
        const LocalAppLogSink(),
        BackendAppLogSink(apiClient: logApiClient),
      ],
    );
    final sessionRepository = DriftSessionRepository(
      database: resolvedLocalDatabase,
      userId: userIdentity.id,
    );

    return AppDependencies(
      analysisService: AnalysisServiceImpl(
        analysisRepository: analysisRepository,
        apiClient: AnalysisApiClient(
          httpClient: resolvedHttpClient,
          apiBaseUri: resolvedConfig.apiBaseUri,
          userId: userIdentity.id,
        ),
      ),
      appLogger: appLogger,
      config: resolvedConfig,
      httpClient: resolvedHttpClient,
      interactionRepository: interactionRepository,
      interactionService: InteractionServiceImpl(
        interactionRepository: interactionRepository,
        apiClient: InteractionApiClient(
          httpClient: resolvedHttpClient,
          apiBaseUri: resolvedConfig.apiBaseUri,
          userId: userIdentity.id,
        ),
      ),
      localDatabase: resolvedLocalDatabase,
      sessionRepository: sessionRepository,
      sessionService: SessionServiceImpl(
        sessionRepository: sessionRepository,
        apiClient: SessionApiClient(
          httpClient: resolvedHttpClient,
          apiBaseUri: resolvedConfig.apiBaseUri,
          userId: userIdentity.id,
        ),
      ),
      userIdentity: userIdentity,
    );
  }

  final AnalysisService analysisService;
  final AppLogger appLogger;
  final AppConfig config;
  final http.Client httpClient;
  final InteractionRepository interactionRepository;
  final InteractionService interactionService;
  final LocalDatabase? localDatabase;
  final SessionRepository sessionRepository;
  final SessionService sessionService;
  final UserIdentity userIdentity;
}
