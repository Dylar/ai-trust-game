import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/logging/log_api_client.dart';

class BackendAppLogSink implements AppLogSink {
  const BackendAppLogSink({required this.apiClient});

  final LogApiClient apiClient;

  @override
  Future<void> write(AppLogEvent event) {
    return apiClient.sendLog(event);
  }
}
