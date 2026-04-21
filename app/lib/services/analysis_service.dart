import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/models/analysis_models.dart';

abstract interface class AnalysisService {
  Future<SessionAnalysis> getSessionAnalysis(String sessionId);

  Future<RequestAnalysis> getRequestAnalysis(String requestId);
}

class AnalysisServiceImpl implements AnalysisService {
  const AnalysisServiceImpl({required this.apiClient});

  final AnalysisApiClient apiClient;

  @override
  Future<SessionAnalysis> getSessionAnalysis(String sessionId) async {
    final response = await apiClient.getSessionAnalysis(sessionId);
    return response.analysis;
  }

  @override
  Future<RequestAnalysis> getRequestAnalysis(String requestId) async {
    final response = await apiClient.getRequestAnalysis(requestId);
    return response.analysis;
  }
}
