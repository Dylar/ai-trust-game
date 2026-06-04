import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/screens/session_start/session_start_screen_state.dart';
import 'package:app/screens/session_start/session_start_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/mocks/recording_app_log_sink.dart';
import '../../testing/mocks/session_service_mocks.dart';

void main() {
  test('logs session preparation start and success', () async {
    final sink = RecordingAppLogSink();
    final viewModel = SessionStartViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      sessionService: const SuccessfulSessionService(),
    );

    await viewModel.prepareSession();

    expect(viewModel.state.value.status, SessionStartStatus.prepared);
    expect(sink.events, hasLength(2));
    expect(sink.events.first.category, 'session_start');
    expect(sink.events.first.message, 'Preparing session');
    expect(sink.events.first.attributes, <String, Object?>{
      'role': 'guest',
      'mode': 'easy',
    });
    expect(sink.events.last.category, 'session_start');
    expect(sink.events.last.message, 'Prepared session');
    expect(sink.events.last.sessionId, 'session-1');
    expect(sink.events.last.attributes, <String, Object?>{
      'sessionId': 'session-1',
      'role': 'guest',
      'mode': 'easy',
    });
  });

  test('logs session preparation error details', () async {
    final sink = RecordingAppLogSink();
    final viewModel = SessionStartViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      sessionService: const ApiFailingSessionService(
        statusCode: 400,
        code: ApiErrorCode.invalidMode,
      ),
    );

    await viewModel.prepareSession();

    expect(viewModel.state.value.status, SessionStartStatus.error);
    expect(sink.events, hasLength(2));
    expect(sink.events.last.level, AppLogLevel.error);
    expect(sink.events.last.message, 'Session preparation failed');
    expect(sink.events.last.attributes, <String, Object?>{
      'role': 'guest',
      'mode': 'easy',
      'httpStatusCode': 400,
      'errorCode': 'invalid_mode',
    });
  });
}
