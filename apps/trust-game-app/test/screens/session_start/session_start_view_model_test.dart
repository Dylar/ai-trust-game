import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/screens/session_start/session_start_screen_state.dart';
import 'package:app/screens/session_start/session_start_view_model.dart';
import 'package:app/services/session_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/mocks/recording_app_log_sink.dart';
import '../../testing/mocks/session_api_mocks.dart';

void main() {
  test('does not log session preparation success path', () async {
    final sink = RecordingAppLogSink();
    final viewModel = SessionStartViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      sessionService: SessionService(
        apiClient: const SuccessfulSessionApi(),
        sessionRepository: InMemorySessionRepository(),
      ),
    );

    await viewModel.prepareSession();

    expect(viewModel.stateNotifier.value.status, SessionStartStatus.prepared);
    expect(sink.events, isEmpty);
  });

  test('logs session preparation error details', () async {
    final sink = RecordingAppLogSink();
    final viewModel = SessionStartViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      sessionService: SessionService(
        apiClient: const ApiFailingSessionApi(
          statusCode: 400,
          code: ApiErrorCode.invalidMode,
        ),
        sessionRepository: InMemorySessionRepository(),
      ),
    );

    await viewModel.prepareSession();

    expect(viewModel.stateNotifier.value.status, SessionStartStatus.error);
    expect(sink.events, hasLength(1));
    expect(sink.events.single.level, AppLogLevel.error);
    expect(sink.events.single.message, 'Session preparation failed');
    expect(sink.events.single.attributes, <String, Object?>{
      'role': 'guest',
      'mode': 'easy',
      'httpStatusCode': 400,
      'errorCode': 'invalid_mode',
    });
  });
}
