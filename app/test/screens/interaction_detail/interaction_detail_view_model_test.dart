import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/models/analysis_models.dart';
import 'package:app/screens/interaction_detail/interaction_detail_screen_state.dart';
import 'package:app/screens/interaction_detail/interaction_detail_view_model.dart';
import 'package:app/services/analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('logs request analysis load start and success', () async {
    final sink = _RecordingSink();
    final viewModel = InteractionDetailViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      analysisService: _SuccessfulAnalysisService(),
      requestId: 'request-1',
    );

    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.value.status, InteractionDetailStatus.ready);
    expect(sink.events, hasLength(2));
    expect(sink.events.first.message, 'Loading request analysis');
    expect(sink.events.first.attributes, <String, Object?>{
      'requestId': 'request-1',
    });
    expect(sink.events.last.message, 'Loaded request analysis');
    expect(sink.events.last.attributes, <String, Object?>{
      'requestId': 'request-1',
      'sessionId': 'session-1',
      'classification': 'suspicious',
    });
  });

  test('logs request analysis load api errors', () async {
    final sink = _RecordingSink();
    final viewModel = InteractionDetailViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      analysisService: const _FailingRequestAnalysisService(),
      requestId: 'request-1',
    );

    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.value.status, InteractionDetailStatus.error);
    expect(sink.events, hasLength(2));
    expect(sink.events.last.message, 'Request analysis loading failed');
    expect(sink.events.last.attributes, <String, Object?>{
      'requestId': 'request-1',
      'httpStatusCode': 404,
      'errorCode': 'request_analysis_not_found',
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
  Future<RequestAnalysis> getRequestAnalysis(String requestId) async {
    return RequestAnalysis(
      requestId: requestId,
      sessionId: 'session-1',
      completedAt: DateTime.utc(2026, 1, 1),
      classification: 'suspicious',
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

class _FailingRequestAnalysisService implements AnalysisService {
  const _FailingRequestAnalysisService();

  @override
  Future<RequestAnalysis> getRequestAnalysis(String requestId) {
    throw const AnalysisApiException(
      statusCode: 404,
      error: ApiError(code: ApiErrorCode.requestAnalysisNotFound),
    );
  }

  @override
  Future<SessionAnalysis> getSessionAnalysis(String sessionId) {
    throw UnimplementedError();
  }
}
