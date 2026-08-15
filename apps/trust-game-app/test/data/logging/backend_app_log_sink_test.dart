import 'dart:async';

import 'package:app/core/logging/app_logger.dart';
import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/data/logging/backend_app_log_sink.dart';
import 'package:app/data/logging/log_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('returns without waiting for backend log delivery', () async {
    final response = Completer<http.Response>();
    final requestStarted = Completer<void>();
    final sink = BackendAppLogSink(
      apiClient: LogApiClient(
        httpClient: MockClient((_) {
          requestStarted.complete();
          return response.future;
        }),
        apiBaseUri: Uri.parse('http://localhost:8080'),
        selectedUser: SelectedUserController(),
      ),
    );

    await sink.write(
      AppLogEvent(
        level: AppLogLevel.info,
        category: 'interaction',
        message: 'message sent',
      ),
    );

    await requestStarted.future;
    expect(response.isCompleted, isFalse);
    response.complete(http.Response('', 202));
  });
}
