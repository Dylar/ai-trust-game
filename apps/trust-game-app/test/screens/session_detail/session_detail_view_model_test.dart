import 'dart:async';

import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/analysis/analysis_api_client.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/models/analysis_models.dart';
import 'package:app/screens/session_detail/session_detail_screen_state.dart';
import 'package:app/screens/session_detail/session_detail_view_model.dart';
import 'package:app/services/analysis_service.dart';
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

  test(
    'shows cached session analysis before backend refresh completes',
    () async {
      final service = _CachedThenFreshSessionAnalysisService();
      final viewModel = SessionDetailViewModel(
        appLogger: AppLogger(sinks: const <AppLogSink>[]),
        analysisService: service,
        sessionId: 'session-1',
      );

      await Future<void>.delayed(Duration.zero);

      expect(viewModel.stateNotifier.value.status, SessionDetailStatus.ready);
      expect(viewModel.stateNotifier.value.analysis?.classification, 'cached');
      expect(viewModel.stateNotifier.value.isRefreshing, isTrue);

      service.completeRefresh();
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

  test(
    'logs refresh errors while keeping cached session analysis visible',
    () async {
      final sink = RecordingAppLogSink();
      final viewModel = SessionDetailViewModel(
        appLogger: AppLogger(sinks: <AppLogSink>[sink]),
        analysisService: _CachedFailingSessionAnalysisService(),
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

class _CachedThenFreshSessionAnalysisService implements AnalysisService {
  var _current = _analysis(classification: 'cached');
  final _refresh = Completer<void>();

  void completeRefresh() {
    _current = _analysis(classification: 'fresh');
    _refresh.complete();
  }

  @override
  Future<RequestAnalysis?> getRequestAnalysis(String requestId) {
    throw UnimplementedError();
  }

  @override
  Future<void> refreshRequestAnalysis(String requestId) {
    throw UnimplementedError();
  }

  @override
  Future<SessionAnalysis?> getSessionAnalysis(String sessionId) async {
    return _current;
  }

  @override
  Future<void> refreshSessionAnalysis(String sessionId) {
    return _refresh.future;
  }
}

class _CachedFailingSessionAnalysisService implements AnalysisService {
  @override
  Future<RequestAnalysis?> getRequestAnalysis(String requestId) {
    throw UnimplementedError();
  }

  @override
  Future<void> refreshRequestAnalysis(String requestId) {
    throw UnimplementedError();
  }

  @override
  Future<SessionAnalysis?> getSessionAnalysis(String sessionId) async {
    return _analysis(classification: 'cached');
  }

  @override
  Future<void> refreshSessionAnalysis(String sessionId) {
    throw AnalysisApiException(
      statusCode: 500,
      error: const ApiError(code: ApiErrorCode.internalError),
    );
  }
}

SessionAnalysis _analysis({required String classification}) {
  return SessionAnalysis(
    sessionId: 'session-1',
    classification: classification,
    signals: const <String>[],
    attackPatterns: const <String>[],
    intentSummary: '',
    requestCount: 0,
    requests: const <RequestAnalysis>[],
    suspicionCount: 0,
    modelFailCount: 0,
  );
}
