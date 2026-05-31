import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/models/session_models.dart';
import 'package:app/screens/interaction/interaction_screen_state.dart';
import 'package:app/screens/interaction/interaction_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/mocks/interaction_service_mocks.dart';
import '../../testing/mocks/recording_app_log_sink.dart';

void main() {
  test('logs interaction submission start and success', () async {
    final sink = RecordingAppLogSink();
    final interactionRepository = InMemoryInteractionRepository();
    final viewModel = InteractionViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      interactionRepository: interactionRepository,
      interactionService: SuccessfulInteractionService(
        interactionRepository: interactionRepository,
      ),
      sessionRepository: InMemorySessionRepository(
        initialSessions: const <Session>[
          Session(id: 'session-1', role: Role.admin, mode: Mode.hard),
        ],
      ),
      sessionId: 'session-1',
    );

    await Future<void>.delayed(Duration.zero);
    await viewModel.submitMessage('Hello there');

    expect(viewModel.state.value.status, InteractionScreenStatus.ready);
    expect(sink.events, hasLength(2));
    expect(sink.events.first.message, 'Submitting interaction message');
    expect(sink.events.first.sessionId, 'session-1');
    expect(sink.events.first.attributes, <String, Object?>{
      'sessionId': 'session-1',
      'messageLength': 11,
    });
    expect(sink.events.last.message, 'Created interaction');
    expect(sink.events.last.sessionId, 'session-1');
    expect(sink.events.last.attributes, <String, Object?>{
      'sessionId': 'session-1',
      'interactionId': 'interaction-1',
      'messageLength': 11,
    });
  });

  test('logs interaction submission api errors', () async {
    final sink = RecordingAppLogSink();
    final viewModel = InteractionViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      interactionRepository: InMemoryInteractionRepository(),
      interactionService: const ApiFailingInteractionService(
        statusCode: 400,
        code: ApiErrorCode.emptyMessage,
      ),
      sessionRepository: InMemorySessionRepository(
        initialSessions: const <Session>[
          Session(id: 'session-1', role: Role.admin, mode: Mode.hard),
        ],
      ),
      sessionId: 'session-1',
    );

    await Future<void>.delayed(Duration.zero);
    await viewModel.submitMessage('Hello there');

    expect(viewModel.state.value.error, isNotNull);
    expect(sink.events, hasLength(2));
    expect(sink.events.last.level, AppLogLevel.error);
    expect(sink.events.last.message, 'Interaction submission failed');
    expect(sink.events.last.attributes, <String, Object?>{
      'sessionId': 'session-1',
      'messageLength': 11,
      'httpStatusCode': 400,
      'errorCode': 'empty_message',
    });
  });
}
