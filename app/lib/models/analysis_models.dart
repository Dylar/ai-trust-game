class RequestAnalysis {
  const RequestAnalysis({
    required this.requestId,
    required this.sessionId,
    required this.completedAt,
    required this.classification,
    required this.signals,
    required this.attackPatterns,
    required this.intentSummary,
    required this.eventCount,
    required this.suspicionCount,
    required this.modelFailCount,
  });

  final String requestId;
  final String sessionId;
  final DateTime completedAt;
  final String classification;
  final List<String> signals;
  final List<String> attackPatterns;
  final String intentSummary;
  final int eventCount;
  final int suspicionCount;
  final int modelFailCount;
}

class SessionAnalysis {
  const SessionAnalysis({
    required this.sessionId,
    required this.classification,
    required this.signals,
    required this.attackPatterns,
    required this.intentSummary,
    required this.requestCount,
    required this.requests,
    required this.suspicionCount,
    required this.modelFailCount,
  });

  final String sessionId;
  final String classification;
  final List<String> signals;
  final List<String> attackPatterns;
  final String intentSummary;
  final int requestCount;
  final List<RequestAnalysis> requests;
  final int suspicionCount;
  final int modelFailCount;
}
