import 'package:app/models/analysis_models.dart';

class RequestAnalysisResponse {
  const RequestAnalysisResponse({required this.analysis});

  final RequestAnalysis analysis;

  factory RequestAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return RequestAnalysisResponse(analysis: _requestAnalysisFromJson(json));
  }
}

class SessionAnalysisResponse {
  const SessionAnalysisResponse({required this.analysis});

  final SessionAnalysis analysis;

  factory SessionAnalysisResponse.fromJson(Map<String, dynamic> json) {
    final requestsJson = json['requests'] as List<dynamic>? ?? <dynamic>[];

    return SessionAnalysisResponse(
      analysis: SessionAnalysis(
        sessionId: json['session_id'] as String,
        classification: json['classification'] as String,
        signals: _stringList(json['signals']),
        attackPatterns: _stringList(json['attack_patterns']),
        intentSummary: json['intent_summary'] as String? ?? '',
        requestCount: json['request_count'] as int,
        requests: requestsJson
            .map(
              (item) => _requestAnalysisFromJson(item as Map<String, dynamic>),
            )
            .toList(growable: false),
        suspicionCount: json['suspicion_count'] as int,
        modelFailCount: json['model_fail_count'] as int,
      ),
    );
  }
}

RequestAnalysis _requestAnalysisFromJson(Map<String, dynamic> json) {
  return RequestAnalysis(
    requestId: json['request_id'] as String,
    sessionId: json['session_id'] as String,
    completedAt: DateTime.parse(json['completed_at'] as String),
    classification: json['classification'] as String,
    signals: _stringList(json['signals']),
    attackPatterns: _stringList(json['attack_patterns']),
    intentSummary: json['intent_summary'] as String? ?? '',
    eventCount: json['event_count'] as int,
    suspicionCount: json['suspicion_count'] as int,
    modelFailCount: json['model_fail_count'] as int,
  );
}

List<String> _stringList(Object? value) {
  final list = value as List<dynamic>? ?? <dynamic>[];
  return list.map((item) => item as String).toList(growable: false);
}
