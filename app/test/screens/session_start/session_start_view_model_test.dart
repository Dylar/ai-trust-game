import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/models/session_models.dart';
import 'package:app/screens/session_start/session_start_screen_state.dart';
import 'package:app/screens/session_start/session_start_view_model.dart';
import 'package:app/services/session_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('logs session preparation start and success', () async {
    final sink = _RecordingSink();
    final viewModel = SessionStartViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      sessionService: _SuccessfulSessionService(),
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
    final sink = _RecordingSink();
    final viewModel = SessionStartViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      sessionService: const _ApiFailingSessionService(),
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

class _RecordingSink implements AppLogSink {
  final List<AppLogEvent> events = <AppLogEvent>[];

  @override
  Future<void> write(AppLogEvent event) async {
    events.add(event);
  }
}

class _SuccessfulSessionService implements SessionService {
  @override
  Future<Session> startSession({required Role role, required Mode mode}) async {
    return Session(id: 'session-1', role: role, mode: mode);
  }
}

class _ApiFailingSessionService implements SessionService {
  const _ApiFailingSessionService();

  @override
  Future<Session> startSession({required Role role, required Mode mode}) {
    throw const ApiException(
      statusCode: 400,
      error: ApiError(code: ApiErrorCode.invalidMode),
    );
  }
}
