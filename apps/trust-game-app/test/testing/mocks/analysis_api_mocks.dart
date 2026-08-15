import 'dart:async';

import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/analysis/analysis_dto.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/models/analysis_models.dart';

class SuccessfulSessionAnalysisApi implements AnalysisApi {
  const SuccessfulSessionAnalysisApi({
    this.sessionId = 'session-1',
    this.requestId = 'request-1',
    this.classification = 'suspicious',
    this.requestCount = 1,
  });

  final String classification;
  final int requestCount;
  final String requestId;
  final String sessionId;

  @override
  Future<RequestAnalysisResponse> getRequestAnalysis(String requestId) {
    throw UnimplementedError();
  }

  @override
  Future<RequestAnalysisResponse> getRequestAnalysisForUser({
    required String userId,
    required String requestId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SessionAnalysisResponse> getSessionAnalysis(String sessionId) async {
    return SessionAnalysisResponse(
      analysis: testSessionAnalysis(
        sessionId: this.sessionId,
        requestId: requestId,
        classification: classification,
        requestCount: requestCount,
      ),
    );
  }

  @override
  Future<SessionAnalysisResponse> getSessionAnalysisForUser({
    required String userId,
    required String sessionId,
  }) {
    throw UnimplementedError();
  }
}

class FailingSessionAnalysisApi implements AnalysisApi {
  const FailingSessionAnalysisApi({
    required this.statusCode,
    required this.code,
  });

  final ApiErrorCode code;
  final int statusCode;

  @override
  Future<RequestAnalysisResponse> getRequestAnalysis(String requestId) {
    throw UnimplementedError();
  }

  @override
  Future<RequestAnalysisResponse> getRequestAnalysisForUser({
    required String userId,
    required String requestId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SessionAnalysisResponse> getSessionAnalysis(String sessionId) {
    throw AnalysisApiException(
      statusCode: statusCode,
      error: ApiError(code: code),
    );
  }

  @override
  Future<SessionAnalysisResponse> getSessionAnalysisForUser({
    required String userId,
    required String sessionId,
  }) {
    throw UnimplementedError();
  }
}

class PendingSessionAnalysisApi implements AnalysisApi {
  PendingSessionAnalysisApi({required this.sessionId});

  final String sessionId;

  final _refresh = Completer<SessionAnalysisResponse>();

  void completeRefresh() {
    _refresh.complete(
      SessionAnalysisResponse(
        analysis: testSessionAnalysis(
          sessionId: sessionId,
          classification: 'fresh',
        ),
      ),
    );
  }

  @override
  Future<SessionAnalysisResponse> getSessionAnalysis(String sessionId) {
    return _refresh.future;
  }

  @override
  Future<SessionAnalysisResponse> getSessionAnalysisForUser({
    required String userId,
    required String sessionId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<RequestAnalysisResponse> getRequestAnalysis(String requestId) {
    throw UnimplementedError();
  }

  @override
  Future<RequestAnalysisResponse> getRequestAnalysisForUser({
    required String userId,
    required String requestId,
  }) {
    throw UnimplementedError();
  }
}

class SuccessfulRequestAnalysisApi implements AnalysisApi {
  const SuccessfulRequestAnalysisApi({
    this.requestId = 'request-1',
    this.sessionId = 'session-1',
    this.classification = 'suspicious',
  });

  final String classification;
  final String requestId;
  final String sessionId;

  @override
  Future<RequestAnalysisResponse> getRequestAnalysis(String requestId) async {
    return RequestAnalysisResponse(
      analysis: testRequestAnalysis(
        requestId: this.requestId,
        sessionId: sessionId,
        classification: classification,
      ),
    );
  }

  @override
  Future<RequestAnalysisResponse> getRequestAnalysisForUser({
    required String userId,
    required String requestId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SessionAnalysisResponse> getSessionAnalysis(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<SessionAnalysisResponse> getSessionAnalysisForUser({
    required String userId,
    required String sessionId,
  }) {
    throw UnimplementedError();
  }
}

class FailingRequestAnalysisApi implements AnalysisApi {
  const FailingRequestAnalysisApi({
    required this.statusCode,
    required this.code,
  });

  final ApiErrorCode code;
  final int statusCode;

  @override
  Future<RequestAnalysisResponse> getRequestAnalysis(String requestId) {
    throw AnalysisApiException(
      statusCode: statusCode,
      error: ApiError(code: code),
    );
  }

  @override
  Future<RequestAnalysisResponse> getRequestAnalysisForUser({
    required String userId,
    required String requestId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SessionAnalysisResponse> getSessionAnalysis(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<SessionAnalysisResponse> getSessionAnalysisForUser({
    required String userId,
    required String sessionId,
  }) {
    throw UnimplementedError();
  }
}

class PendingRequestAnalysisApi implements AnalysisApi {
  PendingRequestAnalysisApi({required this.requestId});

  final String requestId;

  final _refresh = Completer<RequestAnalysisResponse>();

  void completeRefresh() {
    _refresh.complete(
      RequestAnalysisResponse(
        analysis: testRequestAnalysis(
          requestId: requestId,
          classification: 'fresh',
        ),
      ),
    );
  }

  @override
  Future<RequestAnalysisResponse> getRequestAnalysis(String requestId) {
    return _refresh.future;
  }

  @override
  Future<RequestAnalysisResponse> getRequestAnalysisForUser({
    required String userId,
    required String requestId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SessionAnalysisResponse> getSessionAnalysis(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<SessionAnalysisResponse> getSessionAnalysisForUser({
    required String userId,
    required String sessionId,
  }) {
    throw UnimplementedError();
  }
}

SessionAnalysis testSessionAnalysis({
  String sessionId = 'session-1',
  String requestId = 'request-1',
  required String classification,
  int requestCount = 1,
}) {
  return SessionAnalysis(
    sessionId: sessionId,
    classification: classification,
    signals: const <String>['prompt_injection'],
    attackPatterns: const <String>['override'],
    intentSummary: 'Escalation attempt',
    requestCount: requestCount,
    requests: <RequestAnalysis>[
      testRequestAnalysis(
        requestId: requestId,
        sessionId: sessionId,
        classification: classification,
      ),
    ],
    suspicionCount: 1,
    modelFailCount: 0,
  );
}

RequestAnalysis testRequestAnalysis({
  String requestId = 'request-1',
  String sessionId = 'session-1',
  required String classification,
}) {
  return RequestAnalysis(
    requestId: requestId,
    sessionId: sessionId,
    completedAt: DateTime.utc(2026, 1, 1),
    classification: classification,
    signals: const <String>['prompt_injection'],
    attackPatterns: const <String>['override'],
    intentSummary: 'Escalation attempt',
    eventCount: 4,
    suspicionCount: 1,
    modelFailCount: 0,
  );
}
