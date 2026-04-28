import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/models/analysis_models.dart';
import 'package:app/screens/session_detail/session_detail_screen_state.dart';
import 'package:app/screens/session_detail/session_detail_view_model.dart';
import 'package:app/services/analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('logs session analysis load start and success', () async {
    final sink = _RecordingSink();
    final viewModel = SessionDetailViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      analysisService: _SuccessfulAnalysisService(),
      sessionId: 'session-1',
    );

    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.value.status, SessionDetailStatus.ready);
    expect(sink.events, hasLength(2));
    expect(sink.events.first.message, 'Loading session analysis');
    expect(sink.events.first.attributes, <String, Object?>{
      'sessionId': 'session-1',
    });
    expect(sink.events.last.message, 'Loaded session analysis');
    expect(sink.events.last.attributes, <String, Object?>{
      'sessionId': 'session-1',
      'requestCount': 1,
      'classification': 'suspicious',
    });
  });

  test('logs session analysis load api errors', () async {
    final sink = _RecordingSink();
    final viewModel = SessionDetailViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      analysisService: const _FailingSessionAnalysisService(),
      sessionId: 'session-1',
    );

    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.value.status, SessionDetailStatus.error);
    expect(sink.events, hasLength(2));
    expect(sink.events.last.message, 'Session analysis loading failed');
    expect(sink.events.last.attributes, <String, Object?>{
      'sessionId': 'session-1',
      'httpStatusCode': 404,
      'errorCode': 'session_analysis_not_found',
    });
  });
}

class _RecordingSink implements AppLogSink {
  final List<AppLogEvent> events = <AppLogEvent>[];

  @override
  Future<void> write(AppLogEvent event) async {
    events.add(event);
  }
}

class _SuccessfulAnalysisService implements AnalysisService {
  @override
  Future<RequestAnalysis> getRequestAnalysis(String requestId) {
    throw UnimplementedError();
  }

  @override
  Future<SessionAnalysis> getSessionAnalysis(String sessionId) async {
    return SessionAnalysis(
      sessionId: sessionId,
      classification: 'suspicious',
      signals: const <String>['prompt_injection'],
      attackPatterns: const <String>['override'],
      intentSummary: 'Escalation attempt',
      requestCount: 1,
      requests: <RequestAnalysis>[
        RequestAnalysis(
          requestId: 'request-1',
          sessionId: sessionId,
          completedAt: DateTime.utc(2026, 1, 1),
          classification: 'suspicious',
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

class _FailingSessionAnalysisService implements AnalysisService {
  const _FailingSessionAnalysisService();

  @override
  Future<RequestAnalysis> getRequestAnalysis(String requestId) {
    throw UnimplementedError();
  }

  @override
  Future<SessionAnalysis> getSessionAnalysis(String sessionId) {
    throw const AnalysisApiException(
      statusCode: 404,
      error: ApiError(code: ApiErrorCode.sessionAnalysisNotFound),
    );
  }
}
