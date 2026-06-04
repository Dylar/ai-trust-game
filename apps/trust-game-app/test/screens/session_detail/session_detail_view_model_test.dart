import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/screens/session_detail/session_detail_screen_state.dart';
import 'package:app/screens/session_detail/session_detail_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/mocks/analysis_service_mocks.dart';
import '../../testing/mocks/recording_app_log_sink.dart';

void main() {
  test('logs session analysis load start and success', () async {
    final sink = RecordingAppLogSink();
    final viewModel = SessionDetailViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      analysisService: const SuccessfulSessionAnalysisService(),
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
    final sink = RecordingAppLogSink();
    final viewModel = SessionDetailViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      analysisService: const FailingSessionAnalysisService(
        statusCode: 404,
        code: ApiErrorCode.sessionAnalysisNotFound,
      ),
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
