import 'dart:async';
import 'dart:convert';

import 'package:app/models/analysis_models.dart';
import 'package:app/services/analysis_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

MockClient missingRequestAnalysisClient() {
  return MockClient(
    (_) async => http.Response(
      jsonEncode(<String, Object>{
        'error': <String, String>{'code': 'request_analysis_not_found'},
      }),
      404,
    ),
  );
}

class PendingRefreshRequestAnalysisService implements AnalysisService {
  PendingRefreshRequestAnalysisService({required this.requestId})
    : _analysis = _requestAnalysis(
        requestId: requestId,
        classification: 'cached',
      );

  final String requestId;
  late RequestAnalysis _analysis;
  final _refresh = Completer<void>();

  void completeRefresh() {
    _analysis = _requestAnalysis(requestId: requestId, classification: 'fresh');
    _refresh.complete();
  }

  @override
  Future<RequestAnalysis?> getRequestAnalysis(String requestId) async {
    return _analysis;
  }

  @override
  Future<void> refreshRequestAnalysis(String requestId) {
    return _refresh.future;
  }

  @override
  Future<SessionAnalysis?> getSessionAnalysis(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<void> refreshSessionAnalysis(String sessionId) {
    throw UnimplementedError();
  }
}

RequestAnalysis _requestAnalysis({
  required String requestId,
  required String classification,
}) {
  return RequestAnalysis(
    requestId: requestId,
    sessionId: 'session-1',
    completedAt: DateTime.utc(2026, 1, 1),
    classification: classification,
    signals: const <String>[],
    attackPatterns: const <String>[],
    intentSummary: '',
    eventCount: 0,
    suspicionCount: 0,
    modelFailCount: 0,
  );
}
