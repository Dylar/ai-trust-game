import 'package:http/http.dart' as http;

import 'package:app/core/logging/app_logger.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/data/api/api_transport.dart';

class LogApiClient {
  const LogApiClient({
    required this.httpClient,
    required this.apiBaseUri,
    required this.userId,
  });

  final http.Client httpClient;
  final Uri apiBaseUri;
  final String userId;

  Future<void> sendLog(AppLogEvent event) async {
    try {
      final response = await sendPostRequest(
        httpClient,
        apiBaseUri.resolve('/logs/client'),
        headers: buildHeaders(
          userId: userId,
          sessionId: event.sessionId,
          includeJsonContentType: true,
        ),
        body: event.toJson(),
      );

      ensureSuccessResponse(response);
    } on ApiException catch (error) {
      throw LogApiException.fromApiException(error);
    }
  }
}

class LogApiException extends ApiException {
  const LogApiException({required super.statusCode, super.error});

  factory LogApiException.fromApiException(ApiException error) {
    return LogApiException(statusCode: error.statusCode, error: error.error);
  }
}
