import 'package:http/http.dart' as http;

import 'package:app/data/api/api_error.dart';
import 'package:app/data/api/api_transport.dart';
import 'package:app/data/session/start_session_dto.dart';

class SessionApiClient {
  const SessionApiClient({
    required this.httpClient,
    required this.apiBaseUri,
    required this.userId,
  });

  final http.Client httpClient;
  final Uri apiBaseUri;
  final String userId;

  Future<StartSessionResponse> startSession(StartSessionRequest request) async {
    try {
      final json = await sendPostJsonRequest(
        httpClient,
        apiBaseUri.resolve('/session/start'),
        headers: buildHeaders(userId: userId, includeJsonContentType: true),
        body: request.toJson(),
      );
      return StartSessionResponse.fromJson(json);
    } on ApiException catch (error) {
      throw SessionApiException.fromApiException(error);
    }
  }
}

class SessionApiException extends ApiException {
  const SessionApiException({required super.statusCode, super.error});

  factory SessionApiException.fromApiException(ApiException error) {
    return SessionApiException(
      statusCode: error.statusCode,
      error: error.error,
    );
  }
}
