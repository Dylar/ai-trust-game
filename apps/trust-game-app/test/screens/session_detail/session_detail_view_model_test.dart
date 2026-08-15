import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/analysis/analysis_repository.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/models/analysis_models.dart';
import 'package:app/screens/session_detail/session_detail_screen_state.dart';
import 'package:app/screens/session_detail/session_detail_view_model.dart';
import 'package:app/services/analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/mocks/analysis_api_mocks.dart';
import '../../testing/mocks/recording_app_log_sink.dart';

void main() {
  test('does not log session analysis load success path', () async {
    final sink = RecordingAppLogSink();
    final viewModel = SessionDetailViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      analysisService: AnalysisService(
        apiClient: const SuccessfulSessionAnalysisApi(),
        analysisRepository: InMemoryAnalysisRepository(),
      ),
      sessionId: 'session-1',
    );

    await Future<void>.delayed(Duration.zero);

    expect(viewModel.stateNotifier.value.status, SessionDetailStatus.ready);
    expect(sink.events, isEmpty);
  });

  test(
    'shows cached session analysis before backend refresh completes',
    () async {
      final api = PendingSessionAnalysisApi(sessionId: 'session-1');
      final service = AnalysisService(
        apiClient: api,
        analysisRepository: InMemoryAnalysisRepository(
          initialSessionAnalyses: <String, SessionAnalysis>{
            'session-1': testSessionAnalysis(classification: 'cached'),
          },
        ),
      );
      final viewModel = SessionDetailViewModel(
        appLogger: AppLogger(sinks: const <AppLogSink>[]),
        analysisService: service,
        sessionId: 'session-1',
      );

      await Future<void>.delayed(Duration.zero);

      expect(viewModel.stateNotifier.value.status, SessionDetailStatus.ready);
      expect(viewModel.stateNotifier.value.analysis?.classification, 'cached');
      expect(viewModel.stateNotifier.value.isRefreshing, isTrue);

      api.completeRefresh();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.stateNotifier.value.status, SessionDetailStatus.ready);
      expect(viewModel.stateNotifier.value.analysis?.classification, 'fresh');
      expect(viewModel.stateNotifier.value.isRefreshing, isFalse);
    },
  );

  test('does not log missing session analysis as api error', () async {
    final sink = RecordingAppLogSink();
    final viewModel = SessionDetailViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      analysisService: AnalysisService(
        apiClient: const FailingSessionAnalysisApi(
          statusCode: 404,
          code: ApiErrorCode.sessionAnalysisNotFound,
        ),
        analysisRepository: InMemoryAnalysisRepository(),
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
      analysisService: AnalysisService(
        apiClient: const FailingSessionAnalysisApi(
          statusCode: 500,
          code: ApiErrorCode.internalError,
        ),
        analysisRepository: InMemoryAnalysisRepository(),
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

  test(
    'logs refresh errors while keeping cached session analysis visible',
    () async {
      final sink = RecordingAppLogSink();
      final viewModel = SessionDetailViewModel(
        appLogger: AppLogger(sinks: <AppLogSink>[sink]),
        analysisService: AnalysisService(
          apiClient: const FailingSessionAnalysisApi(
            statusCode: 500,
            code: ApiErrorCode.internalError,
          ),
          analysisRepository: InMemoryAnalysisRepository(
            initialSessionAnalyses: <String, SessionAnalysis>{
              'session-1': testSessionAnalysis(classification: 'cached'),
            },
          ),
        ),
        sessionId: 'session-1',
      );

      await Future<void>.delayed(Duration.zero);

      expect(viewModel.stateNotifier.value.status, SessionDetailStatus.ready);
      expect(viewModel.stateNotifier.value.analysis?.classification, 'cached');
      expect(viewModel.stateNotifier.value.isRefreshing, isFalse);
      expect(sink.events, hasLength(1));
      expect(sink.events.single.message, 'Session analysis loading failed');
      expect(sink.events.single.attributes, <String, Object?>{
        'sessionId': 'session-1',
        'httpStatusCode': 500,
        'errorCode': 'internal_error',
      });
    },
  );
}
