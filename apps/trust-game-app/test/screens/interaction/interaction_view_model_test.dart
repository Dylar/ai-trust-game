import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/models/session_models.dart';
import 'package:app/screens/interaction/interaction_screen_state.dart';
import 'package:app/screens/interaction/interaction_view_model.dart';
import 'package:app/services/interaction_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/mocks/interaction_api_mocks.dart';
import '../../testing/mocks/recording_app_log_sink.dart';

void main() {
  test('does not log interaction submission success path', () async {
    final sink = RecordingAppLogSink();
    final interactionRepository = InMemoryInteractionRepository();
    final viewModel = InteractionViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      interactionRepository: interactionRepository,
      interactionService: InteractionService(
        apiClient: const SuccessfulInteractionApi(),
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

    expect(viewModel.stateNotifier.value.status, InteractionScreenStatus.ready);
    expect(sink.events, isEmpty);
  });

  test('logs interaction submission api errors', () async {
    final sink = RecordingAppLogSink();
    final viewModel = InteractionViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      interactionRepository: InMemoryInteractionRepository(),
      interactionService: InteractionService(
        apiClient: const ApiFailingInteractionApi(
          statusCode: 400,
          code: ApiErrorCode.emptyMessage,
        ),
        interactionRepository: InMemoryInteractionRepository(),
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

    expect(viewModel.stateNotifier.value.error, isNotNull);
    expect(sink.events, hasLength(1));
    expect(sink.events.single.level, AppLogLevel.error);
    expect(sink.events.single.message, 'Interaction submission failed');
    expect(sink.events.single.attributes, <String, Object?>{
      'sessionId': 'session-1',
      'messageLength': 11,
      'httpStatusCode': 400,
      'errorCode': 'empty_message',
    });
  });

  test('logs interaction loading errors', () async {
    final sink = RecordingAppLogSink();
    final viewModel = InteractionViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      interactionRepository: InMemoryInteractionRepository(),
      interactionService: InteractionService(
        apiClient: const ApiFailingInteractionApi(
          statusCode: 400,
          code: ApiErrorCode.emptyMessage,
        ),
        interactionRepository: InMemoryInteractionRepository(),
      ),
      sessionRepository: _FailingSessionRepository(),
      sessionId: 'session-1',
    );

    await Future<void>.delayed(Duration.zero);

    expect(viewModel.stateNotifier.value.status, InteractionScreenStatus.error);
    expect(sink.events, hasLength(1));
    expect(sink.events.single.level, AppLogLevel.error);
    expect(sink.events.single.message, 'Interaction loading failed');
    expect(sink.events.single.attributes, <String, Object?>{
      'sessionId': 'session-1',
    });
  });
}

class _FailingSessionRepository implements SessionRepository {
  final ValueNotifier<List<Session>> _sessions = ValueNotifier<List<Session>>(
    const <Session>[],
  );

  @override
  ValueListenable<List<Session>> get sessionsListenable => _sessions;

  @override
  Future<Session?> getSession(String id) async {
    throw Exception('load failed');
  }

  @override
  Future<List<Session>> listSessions() async {
    return const <Session>[];
  }

  @override
  Future<void> saveSession(Session session) async {}

  @override
  Future<void> saveSessionForUser({
    required String userId,
    required Session session,
  }) async {}
}
