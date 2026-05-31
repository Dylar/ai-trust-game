import 'package:app/models/analysis_models.dart';

abstract interface class AnalysisRepository {
  Future<SessionAnalysis?> getSessionAnalysis(String sessionId);

  Future<RequestAnalysis?> getRequestAnalysis(String requestId);

  Future<void> saveSessionAnalysis(SessionAnalysis analysis);

  Future<void> saveRequestAnalysis(RequestAnalysis analysis);
}

class InMemoryAnalysisRepository implements AnalysisRepository {
  InMemoryAnalysisRepository({
    Map<String, SessionAnalysis> initialSessionAnalyses =
        const <String, SessionAnalysis>{},
    Map<String, RequestAnalysis> initialRequestAnalyses =
        const <String, RequestAnalysis>{},
  }) : _sessionAnalyses = Map<String, SessionAnalysis>.of(
         initialSessionAnalyses,
       ),
       _requestAnalyses = Map<String, RequestAnalysis>.of(
         initialRequestAnalyses,
       );

  final Map<String, SessionAnalysis> _sessionAnalyses;
  final Map<String, RequestAnalysis> _requestAnalyses;

  @override
  Future<SessionAnalysis?> getSessionAnalysis(String sessionId) async {
    return _sessionAnalyses[sessionId];
  }

  @override
  Future<RequestAnalysis?> getRequestAnalysis(String requestId) async {
    return _requestAnalyses[requestId];
  }

  @override
  Future<void> saveSessionAnalysis(SessionAnalysis analysis) async {
    _sessionAnalyses[analysis.sessionId] = analysis;
    for (final request in analysis.requests) {
      _requestAnalyses[request.requestId] = request;
    }
  }

  @override
  Future<void> saveRequestAnalysis(RequestAnalysis analysis) async {
    _requestAnalyses[analysis.requestId] = analysis;
  }
}
