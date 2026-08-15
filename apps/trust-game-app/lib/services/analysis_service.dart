import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/analysis/analysis_repository.dart';
import 'package:app/models/analysis_models.dart';

class AnalysisService {
  const AnalysisService({
    required this.apiClient,
    required this.analysisRepository,
  });

  final AnalysisApi apiClient;
  final AnalysisRepository analysisRepository;

  Future<SessionAnalysis?> getSessionAnalysis(String sessionId) {
    return analysisRepository.getSessionAnalysis(sessionId);
  }

  Future<void> refreshSessionAnalysis(String sessionId) async {
    final response = await apiClient.getSessionAnalysis(sessionId);
    await analysisRepository.saveSessionAnalysis(response.analysis);
  }

  Future<RequestAnalysis?> getRequestAnalysis(String requestId) {
    return analysisRepository.getRequestAnalysis(requestId);
  }

  Future<void> refreshRequestAnalysis(String requestId) async {
    final response = await apiClient.getRequestAnalysis(requestId);
    await analysisRepository.saveRequestAnalysis(response.analysis);
  }
}
