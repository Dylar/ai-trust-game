import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/models/analysis_models.dart';
import 'package:app/services/analysis_service.dart';

class SuccessfulSessionAnalysisService implements AnalysisService {
  const SuccessfulSessionAnalysisService({
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
  Future<RequestAnalysis> getRequestAnalysis(String requestId) {
    throw UnimplementedError();
  }

  @override
  Future<SessionAnalysis> getSessionAnalysis(String sessionId) async {
    return SessionAnalysis(
      sessionId: this.sessionId,
      classification: classification,
      signals: const <String>['prompt_injection'],
      attackPatterns: const <String>['override'],
      intentSummary: 'Escalation attempt',
      requestCount: requestCount,
      requests: <RequestAnalysis>[
        RequestAnalysis(
          requestId: requestId,
          sessionId: this.sessionId,
          completedAt: DateTime.utc(2026, 1, 1),
          classification: classification,
          signals: const <String>['prompt_injection'],
          attackPatterns: const <String>['override'],
          intentSummary: 'Escalation attempt',
          eventCount: 4,
          suspicionCount: 1,
          modelFailCount: 0,
        ),
      ],
      suspicionCount: 1,
      modelFailCount: 0,
    );
  }
}

class FailingSessionAnalysisService implements AnalysisService {
  const FailingSessionAnalysisService({
    required this.statusCode,
    required this.code,
  });

  final ApiErrorCode code;
  final int statusCode;

  @override
  Future<RequestAnalysis> getRequestAnalysis(String requestId) {
    throw UnimplementedError();
  }

  @override
  Future<SessionAnalysis> getSessionAnalysis(String sessionId) {
    throw AnalysisApiException(
      statusCode: statusCode,
      error: ApiError(code: code),
    );
  }
}

class SuccessfulRequestAnalysisService implements AnalysisService {
  const SuccessfulRequestAnalysisService({
    this.requestId = 'request-1',
    this.sessionId = 'session-1',
    this.classification = 'suspicious',
  });

  final String classification;
  final String requestId;
  final String sessionId;

  @override
  Future<RequestAnalysis> getRequestAnalysis(String requestId) async {
    return RequestAnalysis(
      requestId: this.requestId,
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

  @override
  Future<SessionAnalysis> getSessionAnalysis(String sessionId) {
    throw UnimplementedError();
  }
}

class FailingRequestAnalysisService implements AnalysisService {
  const FailingRequestAnalysisService({
    required this.statusCode,
    required this.code,
  });

  final ApiErrorCode code;
  final int statusCode;

  @override
  Future<RequestAnalysis> getRequestAnalysis(String requestId) {
    throw AnalysisApiException(
      statusCode: statusCode,
      error: ApiError(code: code),
    );
  }

  @override
  Future<SessionAnalysis> getSessionAnalysis(String sessionId) {
    throw UnimplementedError();
  }
}
