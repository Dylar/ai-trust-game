import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/data/interaction/interaction_repository.dart';
import 'package:app/data/session/session_repository.dart';
import 'package:app/models/interaction_models.dart';
import 'package:app/models/session_models.dart';
import 'package:app/screens/interaction/interaction_screen_state.dart';
import 'package:app/screens/interaction/interaction_view_model.dart';
import 'package:app/services/interaction_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('logs interaction submission start and success', () async {
    final sink = _RecordingSink();
    final interactionRepository = InMemoryInteractionRepository();
    final viewModel = InteractionViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      interactionRepository: interactionRepository,
      interactionService: _SuccessfulInteractionService(
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
    final sink = _RecordingSink();
    final viewModel = InteractionViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      interactionRepository: InMemoryInteractionRepository(),
      interactionService: const _ApiFailingInteractionService(),
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

class _RecordingSink implements AppLogSink {
  final List<AppLogEvent> events = <AppLogEvent>[];

  @override
  Future<void> write(AppLogEvent event) async {
    events.add(event);
  }
}

class _SuccessfulInteractionService implements InteractionService {
  const _SuccessfulInteractionService({required this.interactionRepository});

  final InteractionRepository interactionRepository;

  @override
  Future<Interaction> createInteraction({
    required String sessionId,
    required String message,
  }) async {
    final interaction = Interaction(
      sessionId: sessionId,
      interactionId: 'interaction-1',
      message: message,
      answer: 'Hi back',
    );
    await interactionRepository.saveInteraction(interaction);
    return interaction;
  }
}

class _ApiFailingInteractionService implements InteractionService {
  const _ApiFailingInteractionService();

  @override
  Future<Interaction> createInteraction({
    required String sessionId,
    required String message,
  }) {
    throw const ApiException(
      statusCode: 400,
      error: ApiError(code: ApiErrorCode.emptyMessage),
    );
  }
}
