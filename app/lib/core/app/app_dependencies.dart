import 'package:app/core/config/app_config.dart';
import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/logging/backend_app_log_sink.dart';
import 'package:app/core/logging/local_app_log_sink.dart';
import 'package:app/core/user/user_identity.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/analysis/analysis_repository.dart';
import 'package:app/data/interaction/interaction_api_client.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/logging/log_api_client.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/services/analysis_service.dart';
import 'package:app/services/interaction_service.dart';
import 'package:app/services/session_service.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class AppDependenciesData {
  const AppDependenciesData({
    required this.analysisService,
    required this.appLogger,
    required this.config,
    required this.httpClient,
    required this.interactionRepository,
    required this.interactionService,
    required this.sessionRepository,
    required this.sessionService,
    required this.userIdentity,
  });

  factory AppDependenciesData.defaults() {
    final config = AppConfig.fromEnvironment();
    final httpClient = http.Client();
    final userIdentity = UserIdentity.newRuntimeIdentity();
    final analysisRepository = InMemoryAnalysisRepository();
    final interactionRepository = InMemoryInteractionRepository();
    final logApiClient = LogApiClient(
      httpClient: httpClient,
      apiBaseUri: config.apiBaseUri,
      userId: userIdentity.id,
    );
    final appLogger = AppLogger(
      sinks: <AppLogSink>[
        const LocalAppLogSink(),
        BackendAppLogSink(apiClient: logApiClient),
      ],
    );
    final sessionRepository = InMemorySessionRepository();

    return AppDependenciesData(
      analysisService: AnalysisServiceImpl(
        analysisRepository: analysisRepository,
        apiClient: AnalysisApiClient(
          httpClient: httpClient,
          apiBaseUri: config.apiBaseUri,
          userId: userIdentity.id,
        ),
      ),
      appLogger: appLogger,
      config: config,
      httpClient: httpClient,
      interactionRepository: interactionRepository,
      interactionService: InteractionServiceImpl(
        interactionRepository: interactionRepository,
        apiClient: InteractionApiClient(
          httpClient: httpClient,
          apiBaseUri: config.apiBaseUri,
          userId: userIdentity.id,
        ),
      ),
      sessionRepository: sessionRepository,
      sessionService: SessionServiceImpl(
        sessionRepository: sessionRepository,
        apiClient: SessionApiClient(
          httpClient: httpClient,
          apiBaseUri: config.apiBaseUri,
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
  final SessionRepository sessionRepository;
  final SessionService sessionService;
  final UserIdentity userIdentity;
}

class AppDependencies extends InheritedWidget {
  const AppDependencies({
    super.key,
    required this.dependencies,
    required super.child,
  });

  final AppDependenciesData dependencies;

  AnalysisService get analysisService => dependencies.analysisService;
  AppLogger get appLogger => dependencies.appLogger;
  AppConfig get config => dependencies.config;
  http.Client get httpClient => dependencies.httpClient;
  InteractionRepository get interactionRepository =>
      dependencies.interactionRepository;
  InteractionService get interactionService => dependencies.interactionService;
  SessionRepository get sessionRepository => dependencies.sessionRepository;
  SessionService get sessionService => dependencies.sessionService;
  UserIdentity get userIdentity => dependencies.userIdentity;

  static AppDependencies of(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<AppDependencies>();
    assert(widget != null, 'AppDependencies is missing above this context.');
    return widget!;
  }

  @override
  bool updateShouldNotify(AppDependencies oldWidget) {
    return oldWidget.dependencies != dependencies;
  }
}
