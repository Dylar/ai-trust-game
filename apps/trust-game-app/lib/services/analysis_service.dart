import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/analysis/analysis_repository.dart';
import 'package:app/models/analysis_models.dart';

abstract interface class AnalysisService {
  Future<SessionAnalysis> getSessionAnalysis(String sessionId);

  Future<RequestAnalysis> getRequestAnalysis(String requestId);
}

class AnalysisServiceImpl implements AnalysisService {
  const AnalysisServiceImpl({
    required this.apiClient,
    required this.analysisRepository,
  });

  final AnalysisApiClient apiClient;
  final AnalysisRepository analysisRepository;

  @override
  Future<SessionAnalysis> getSessionAnalysis(String sessionId) async {
    final cached = await analysisRepository.getSessionAnalysis(sessionId);
    if (cached != null) {
      return cached;
    }

    final response = await apiClient.getSessionAnalysis(sessionId);
    await analysisRepository.saveSessionAnalysis(response.analysis);
    return response.analysis;
  }

  @override
  Future<RequestAnalysis> getRequestAnalysis(String requestId) async {
    final cached = await analysisRepository.getRequestAnalysis(requestId);
    if (cached != null) {
      return cached;
    }

    final response = await apiClient.getRequestAnalysis(requestId);
    await analysisRepository.saveRequestAnalysis(response.analysis);
    return response.analysis;
  }
}
