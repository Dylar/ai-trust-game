import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/analysis/analysis_repository.dart';
import 'package:app/models/analysis_models.dart';

abstract interface class AnalysisService {
  Future<SessionAnalysis?> getSessionAnalysis(String sessionId);

  Future<void> refreshSessionAnalysis(String sessionId);

  Future<RequestAnalysis?> getRequestAnalysis(String requestId);

  Future<void> refreshRequestAnalysis(String requestId);
}

class AnalysisServiceImpl implements AnalysisService {
  const AnalysisServiceImpl({
    required this.apiClient,
    required this.analysisRepository,
  });

  final AnalysisApiClient apiClient;
  final AnalysisRepository analysisRepository;

  @override
  Future<SessionAnalysis?> getSessionAnalysis(String sessionId) {
    return analysisRepository.getSessionAnalysis(sessionId);
  }

  @override
  Future<void> refreshSessionAnalysis(String sessionId) async {
    final response = await apiClient.getSessionAnalysis(sessionId);
    await analysisRepository.saveSessionAnalysis(response.analysis);
  }

  @override
  Future<RequestAnalysis?> getRequestAnalysis(String requestId) {
    return analysisRepository.getRequestAnalysis(requestId);
  }

  @override
  Future<void> refreshRequestAnalysis(String requestId) async {
    final response = await apiClient.getRequestAnalysis(requestId);
    await analysisRepository.saveRequestAnalysis(response.analysis);
  }
}
