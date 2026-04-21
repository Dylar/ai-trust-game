import 'package:http/http.dart' as http;

import 'package:app/core/app/app_dependencies.dart';
import 'package:app/core/config/app_config.dart';
import 'package:app/data/interaction/interaction_api_client.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/services/interaction_service.dart';
import 'package:app/services/session_service.dart';

AppDependenciesData buildTestDependencies({
  InteractionRepository? interactionRepository,
  SessionRepository? sessionRepository,
}) {
  final config = AppConfig(apiBaseUri: Uri.parse('http://localhost:8080'));
  final httpClient = http.Client();
  final resolvedInteractionRepository =
      interactionRepository ?? InMemoryInteractionRepository();
  final resolvedSessionRepository =
      sessionRepository ?? InMemorySessionRepository();

  return AppDependenciesData(
    config: config,
    httpClient: httpClient,
    interactionRepository: resolvedInteractionRepository,
    interactionService: InteractionServiceImpl(
      apiClient: InteractionApiClient(
        httpClient: httpClient,
        apiBaseUri: config.apiBaseUri,
      ),
      interactionRepository: resolvedInteractionRepository,
    ),
    sessionRepository: resolvedSessionRepository,
    sessionService: SessionServiceImpl(
      apiClient: SessionApiClient(
        httpClient: httpClient,
        apiBaseUri: config.apiBaseUri,
      ),
      sessionRepository: resolvedSessionRepository,
    ),
  );
}
