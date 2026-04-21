import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'package:app/core/config/app_config.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/interaction/interaction_api_client.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/services/analysis_service.dart';
import 'package:app/services/interaction_service.dart';
import 'package:app/services/session_service.dart';

class AppDependenciesData {
  const AppDependenciesData({
    required this.analysisService,
    required this.config,
    required this.httpClient,
    required this.interactionRepository,
    required this.interactionService,
    required this.sessionRepository,
    required this.sessionService,
  });

  factory AppDependenciesData.defaults() {
    final config = AppConfig.fromEnvironment();
    final httpClient = http.Client();
    final interactionRepository = InMemoryInteractionRepository();
    final sessionRepository = InMemorySessionRepository();

    return AppDependenciesData(
      analysisService: AnalysisServiceImpl(
        apiClient: AnalysisApiClient(
          httpClient: httpClient,
          apiBaseUri: config.apiBaseUri,
        ),
      ),
      config: config,
      httpClient: httpClient,
      interactionRepository: interactionRepository,
      interactionService: InteractionServiceImpl(
        interactionRepository: interactionRepository,
        apiClient: InteractionApiClient(
          httpClient: httpClient,
          apiBaseUri: config.apiBaseUri,
        ),
      ),
      sessionRepository: sessionRepository,
      sessionService: SessionServiceImpl(
        sessionRepository: sessionRepository,
        apiClient: SessionApiClient(
          httpClient: httpClient,
          apiBaseUri: config.apiBaseUri,
        ),
      ),
    );
  }

  final AnalysisService analysisService;
  final AppConfig config;
  final http.Client httpClient;
  final InteractionRepository interactionRepository;
  final InteractionService interactionService;
  final SessionRepository sessionRepository;
  final SessionService sessionService;
}

class AppDependencies extends InheritedWidget {
  const AppDependencies({
    super.key,
    required this.dependencies,
    required super.child,
  });

  final AppDependenciesData dependencies;

  AnalysisService get analysisService => dependencies.analysisService;
  AppConfig get config => dependencies.config;
  http.Client get httpClient => dependencies.httpClient;
  InteractionRepository get interactionRepository =>
      dependencies.interactionRepository;
  InteractionService get interactionService => dependencies.interactionService;
  SessionRepository get sessionRepository => dependencies.sessionRepository;
  SessionService get sessionService => dependencies.sessionService;

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
