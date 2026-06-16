import 'dart:async';

import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/models/analysis_models.dart';
import 'package:app/screens/interaction_detail/interaction_detail_screen_state.dart';
import 'package:app/screens/interaction_detail/interaction_detail_view_model.dart';
import 'package:app/services/analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/mocks/analysis_service_mocks.dart';
import '../../testing/mocks/recording_app_log_sink.dart';

void main() {
  test('does not log request analysis load success path', () async {
    final sink = RecordingAppLogSink();
    final viewModel = InteractionDetailViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      analysisService: const SuccessfulRequestAnalysisService(),
      requestId: 'request-1',
    );

    await Future<void>.delayed(Duration.zero);

    expect(viewModel.stateNotifier.value.status, InteractionDetailStatus.ready);
    expect(sink.events, isEmpty);
  });

  test(
    'shows cached request analysis before backend refresh completes',
    () async {
      final service = _CachedThenFreshRequestAnalysisService();
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

      service.completeRefresh();
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
      analysisService: const FailingRequestAnalysisService(
        statusCode: 404,
        code: ApiErrorCode.requestAnalysisNotFound,
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
      analysisService: const FailingRequestAnalysisService(
        statusCode: 500,
        code: ApiErrorCode.internalError,
      ),
      requestId: 'request-1',
    );

    await Future<void>.delayed(Duration.zero);

    expect(viewModel.stateNotifier.value.status, InteractionDetailStatus.error);
    expect(sink.events, hasLength(1));
    expect(sink.events.single.message, 'Request analysis loading failed');
    expect(sink.events.single.attributes, <String, Object?>{
      'requestId': 'request-1',
      'httpStatusCode': 500,
      'errorCode': 'internal_error',
    });
  });

  test(
    'logs refresh errors while keeping cached request analysis visible',
    () async {
      final sink = RecordingAppLogSink();
      final viewModel = InteractionDetailViewModel(
        appLogger: AppLogger(sinks: <AppLogSink>[sink]),
        analysisService: _CachedFailingRequestAnalysisService(),
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
        'httpStatusCode': 500,
        'errorCode': 'internal_error',
      });
    },
  );
}

class _CachedThenFreshRequestAnalysisService implements AnalysisService {
  var _current = _analysis(classification: 'cached');
  final _refresh = Completer<void>();

  void completeRefresh() {
    _current = _analysis(classification: 'fresh');
    _refresh.complete();
  }

  @override
  Future<RequestAnalysis?> getRequestAnalysis(String requestId) async {
    return _current;
  }

  @override
  Future<void> refreshRequestAnalysis(String requestId) {
    return _refresh.future;
  }

  @override
  Future<SessionAnalysis?> getSessionAnalysis(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<void> refreshSessionAnalysis(String sessionId) {
    throw UnimplementedError();
  }
}

class _CachedFailingRequestAnalysisService implements AnalysisService {
  @override
  Future<RequestAnalysis?> getRequestAnalysis(String requestId) async {
    return _analysis(classification: 'cached');
  }

  @override
  Future<void> refreshRequestAnalysis(String requestId) {
    throw AnalysisApiException(
      statusCode: 500,
      error: const ApiError(code: ApiErrorCode.internalError),
    );
  }

  @override
  Future<SessionAnalysis?> getSessionAnalysis(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<void> refreshSessionAnalysis(String sessionId) {
    throw UnimplementedError();
  }
}

RequestAnalysis _analysis({required String classification}) {
  return RequestAnalysis(
    requestId: 'request-1',
    sessionId: 'session-1',
    completedAt: DateTime.utc(2026, 1, 1),
    classification: classification,
    signals: const <String>[],
    attackPatterns: const <String>[],
    intentSummary: '',
    eventCount: 0,
    suspicionCount: 0,
    modelFailCount: 0,
  );
}
