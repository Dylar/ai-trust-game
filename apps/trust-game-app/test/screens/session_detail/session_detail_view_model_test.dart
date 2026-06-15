import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/screens/session_detail/session_detail_screen_state.dart';
import 'package:app/screens/session_detail/session_detail_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/mocks/analysis_service_mocks.dart';
import '../../testing/mocks/recording_app_log_sink.dart';

void main() {
  test('does not log session analysis load success path', () async {
    final sink = RecordingAppLogSink();
    final viewModel = SessionDetailViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      analysisService: const SuccessfulSessionAnalysisService(),
      sessionId: 'session-1',
    );

    await Future<void>.delayed(Duration.zero);

    expect(viewModel.stateNotifier.value.status, SessionDetailStatus.ready);
    expect(sink.events, isEmpty);
  });

  test('does not log missing session analysis as api error', () async {
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

    expect(
      viewModel.stateNotifier.value.status,
      SessionDetailStatus.notAvailableYet,
    );
    expect(sink.events, isEmpty);
  });

  test('logs session analysis load api errors', () async {
    final sink = RecordingAppLogSink();
    final viewModel = SessionDetailViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      analysisService: const FailingSessionAnalysisService(
        statusCode: 500,
        code: ApiErrorCode.internalError,
      ),
      sessionId: 'session-1',
    );

    await Future<void>.delayed(Duration.zero);

    expect(viewModel.stateNotifier.value.status, SessionDetailStatus.error);
    expect(sink.events, hasLength(1));
    expect(sink.events.single.message, 'Session analysis loading failed');
    expect(sink.events.single.attributes, <String, Object?>{
      'sessionId': 'session-1',
      'httpStatusCode': 500,
      'errorCode': 'internal_error',
    });
  });
}
