import 'dart:io';

import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/analysis/analysis_repository.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/models/analysis_models.dart';
import 'package:app/screens/interaction_detail/interaction_detail_screen_state.dart';
import 'package:app/screens/interaction_detail/interaction_detail_view_model.dart';
import 'package:app/services/analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/mocks/analysis_api_mocks.dart';
import '../../testing/mocks/recording_app_log_sink.dart';

void main() {
  test('does not log request analysis load success path', () async {
    final sink = RecordingAppLogSink();
    final viewModel = InteractionDetailViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      analysisService: AnalysisService(
        apiClient: const SuccessfulRequestAnalysisApi(),
        analysisRepository: InMemoryAnalysisRepository(),
      ),
      requestId: 'request-1',
    );

    await Future<void>.delayed(Duration.zero);

    expect(viewModel.stateNotifier.value.status, InteractionDetailStatus.ready);
    expect(sink.events, isEmpty);
  });

  test(
    'shows cached request analysis before backend refresh completes',
    () async {
      final api = PendingRequestAnalysisApi(requestId: 'request-1');
      final service = AnalysisService(
        apiClient: api,
        analysisRepository: InMemoryAnalysisRepository(
          initialRequestAnalyses: <String, RequestAnalysis>{
            'request-1': testRequestAnalysis(classification: 'cached'),
          },
        ),
      );
      final viewModel = InteractionDetailViewModel(
        appLogger: AppLogger(sinks: const <AppLogSink>[]),
        analysisService: service,
        requestId: 'request-1',
      );

      await Future<void>.delayed(Duration.zero);

      expect(
        viewModel.stateNotifier.value.status,
        InteractionDetailStatus.ready,
      );
      expect(viewModel.stateNotifier.value.analysis?.classification, 'cached');
      expect(viewModel.stateNotifier.value.isRefreshing, isTrue);

      api.completeRefresh();
      await Future<void>.delayed(Duration.zero);

      expect(
        viewModel.stateNotifier.value.status,
        InteractionDetailStatus.ready,
      );
      expect(viewModel.stateNotifier.value.analysis?.classification, 'fresh');
      expect(viewModel.stateNotifier.value.isRefreshing, isFalse);
    },
  );

  test('does not log missing request analysis as api error', () async {
    final sink = RecordingAppLogSink();
    final viewModel = InteractionDetailViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      analysisService: AnalysisService(
        apiClient: const FailingRequestAnalysisApi(
          statusCode: HttpStatus.notFound,
          code: ApiErrorCode.requestAnalysisNotFound,
        ),
        analysisRepository: InMemoryAnalysisRepository(),
      ),
      requestId: 'request-1',
    );

    await Future<void>.delayed(Duration.zero);

    expect(
      viewModel.stateNotifier.value.status,
      InteractionDetailStatus.notAvailableYet,
    );
    expect(sink.events, isEmpty);
  });

  test('logs request analysis load api errors', () async {
    final sink = RecordingAppLogSink();
    final viewModel = InteractionDetailViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      analysisService: AnalysisService(
        apiClient: const FailingRequestAnalysisApi(
          statusCode: HttpStatus.internalServerError,
          code: ApiErrorCode.internalError,
        ),
        analysisRepository: InMemoryAnalysisRepository(),
      ),
      requestId: 'request-1',
    );

    await Future<void>.delayed(Duration.zero);

    expect(viewModel.stateNotifier.value.status, InteractionDetailStatus.error);
    expect(sink.events, hasLength(1));
    expect(sink.events.single.message, 'Request analysis loading failed');
    expect(sink.events.single.attributes, <String, Object?>{
      'requestId': 'request-1',
      'httpStatusCode': HttpStatus.internalServerError,
      'errorCode': 'internal_error',
    });
  });

  test(
    'logs refresh errors while keeping cached request analysis visible',
    () async {
      final sink = RecordingAppLogSink();
      final viewModel = InteractionDetailViewModel(
        appLogger: AppLogger(sinks: <AppLogSink>[sink]),
        analysisService: AnalysisService(
          apiClient: const FailingRequestAnalysisApi(
            statusCode: HttpStatus.internalServerError,
            code: ApiErrorCode.internalError,
          ),
          analysisRepository: InMemoryAnalysisRepository(
            initialRequestAnalyses: <String, RequestAnalysis>{
              'request-1': testRequestAnalysis(classification: 'cached'),
            },
          ),
        ),
        requestId: 'request-1',
      );

      await Future<void>.delayed(Duration.zero);

      expect(
        viewModel.stateNotifier.value.status,
        InteractionDetailStatus.ready,
      );
      expect(viewModel.stateNotifier.value.analysis?.classification, 'cached');
      expect(viewModel.stateNotifier.value.isRefreshing, isFalse);
      expect(sink.events, hasLength(1));
      expect(sink.events.single.message, 'Request analysis loading failed');
      expect(sink.events.single.attributes, <String, Object?>{
        'requestId': 'request-1',
        'httpStatusCode': HttpStatus.internalServerError,
        'errorCode': 'internal_error',
      });
    },
  );
}
