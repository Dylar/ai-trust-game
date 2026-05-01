import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/screens/interaction_detail/interaction_detail_screen_state.dart';
import 'package:app/screens/interaction_detail/interaction_detail_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/mocks/analysis_service_mocks.dart';
import '../../testing/mocks/recording_app_log_sink.dart';

void main() {
  test('logs request analysis load start and success', () async {
    final sink = RecordingAppLogSink();
    final viewModel = InteractionDetailViewModel(
      appLogger: AppLogger(sinks: <AppLogSink>[sink]),
      analysisService: const SuccessfulRequestAnalysisService(),
      requestId: 'request-1',
    );

    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.value.status, InteractionDetailStatus.ready);
    expect(sink.events, hasLength(2));
    expect(sink.events.first.message, 'Loading request analysis');
    expect(sink.events.first.attributes, <String, Object?>{
      'requestId': 'request-1',
    });
    expect(sink.events.last.message, 'Loaded request analysis');
    expect(sink.events.last.attributes, <String, Object?>{
      'requestId': 'request-1',
      'sessionId': 'session-1',
      'classification': 'suspicious',
    });
  });

  test('logs request analysis load api errors', () async {
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

    expect(viewModel.state.value.status, InteractionDetailStatus.error);
    expect(sink.events, hasLength(2));
    expect(sink.events.last.message, 'Request analysis loading failed');
    expect(sink.events.last.attributes, <String, Object?>{
      'requestId': 'request-1',
      'httpStatusCode': 404,
      'errorCode': 'request_analysis_not_found',
    });
  });
}
