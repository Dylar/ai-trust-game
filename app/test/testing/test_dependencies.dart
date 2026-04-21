import 'package:http/http.dart' as http;

import 'package:app/core/app/app_dependencies.dart';
import 'package:app/core/config/app_config.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/interaction/interaction_api_client.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/session_api_client.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/services/analysis_service.dart';
import 'package:app/services/interaction_service.dart';
import 'package:app/services/session_service.dart';
import 'mocks/backend_mock_client.dart';

AppDependenciesData buildTestDependencies({
  AnalysisService? analysisService,
  http.Client? httpClient,
  InteractionRepository? interactionRepository,
  SessionRepository? sessionRepository,
}) {
  final config = AppConfig(apiBaseUri: Uri.parse('http://localhost:8080'));
  final resolvedHttpClient = httpClient ?? buildBackendMockClient();
  final resolvedInteractionRepository =
      interactionRepository ?? InMemoryInteractionRepository();
  final resolvedSessionRepository =
      sessionRepository ?? InMemorySessionRepository();

  return AppDependenciesData(
    analysisService:
        analysisService ??
        AnalysisServiceImpl(
          apiClient: AnalysisApiClient(
            httpClient: resolvedHttpClient,
            apiBaseUri: config.apiBaseUri,
          ),
        ),
    config: config,
    httpClient: resolvedHttpClient,
    interactionRepository: resolvedInteractionRepository,
    interactionService: InteractionServiceImpl(
      apiClient: InteractionApiClient(
        httpClient: resolvedHttpClient,
        apiBaseUri: config.apiBaseUri,
      ),
      interactionRepository: resolvedInteractionRepository,
    ),
    sessionRepository: resolvedSessionRepository,
    sessionService: SessionServiceImpl(
      apiClient: SessionApiClient(
        httpClient: resolvedHttpClient,
        apiBaseUri: config.apiBaseUri,
      ),
      sessionRepository: resolvedSessionRepository,
    ),
  );
}
