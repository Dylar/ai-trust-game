import 'dart:async';
import 'dart:convert';

import 'package:app/models/analysis_models.dart';
import 'package:app/services/analysis_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

MockClient missingSessionAnalysisClient() {
  return MockClient(
    (_) async => http.Response(
      jsonEncode(<String, Object>{
        'error': <String, String>{'code': 'session_analysis_not_found'},
      }),
      404,
    ),
  );
}

class PendingRefreshSessionAnalysisService implements AnalysisService {
  PendingRefreshSessionAnalysisService({required this.sessionId})
    : _analysis = _sessionAnalysis(
        sessionId: sessionId,
        classification: 'cached',
      );

  final String sessionId;
  late SessionAnalysis _analysis;
  final _refresh = Completer<void>();

  void completeRefresh() {
    _analysis = _sessionAnalysis(sessionId: sessionId, classification: 'fresh');
    _refresh.complete();
  }

  @override
  Future<RequestAnalysis?> getRequestAnalysis(String requestId) {
    throw UnimplementedError();
  }

  @override
  Future<void> refreshRequestAnalysis(String requestId) {
    throw UnimplementedError();
  }

  @override
  Future<SessionAnalysis?> getSessionAnalysis(String sessionId) async {
    return _analysis;
  }

  @override
  Future<void> refreshSessionAnalysis(String sessionId) {
    return _refresh.future;
  }
}

SessionAnalysis _sessionAnalysis({
  required String sessionId,
  required String classification,
}) {
  return SessionAnalysis(
    sessionId: sessionId,
    classification: classification,
    signals: const <String>[],
    attackPatterns: const <String>[],
    intentSummary: '',
    requestCount: 0,
    requests: const <RequestAnalysis>[],
    suspicionCount: 0,
    modelFailCount: 0,
  );
}
