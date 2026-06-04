import 'package:http/http.dart' as http;

import 'package:app/data/api/api_error.dart';
import 'package:app/data/api/api_transport.dart';
import 'package:app/data/interaction/interaction_dto.dart';

class InteractionApiClient {
  const InteractionApiClient({
    required this.httpClient,
    required this.apiBaseUri,
    required this.userId,
  });

  final http.Client httpClient;
  final Uri apiBaseUri;
  final String userId;

  Future<InteractionResponse> createInteraction(
    InteractionRequest request,
  ) async {
    try {
      final response = await sendPostRequest(
        httpClient,
        apiBaseUri.resolve('/interaction'),
        headers: buildHeaders(
          userId: userId,
          sessionId: request.sessionId,
          includeJsonContentType: true,
        ),
        body: request.toJson(),
      );

      final requestId =
          response.headers['x-request-id'] ??
          'local-${DateTime.now().microsecondsSinceEpoch}';

      return InteractionResponse.fromBackend(
        sessionId: request.sessionId,
        requestId: requestId,
        requestMessage: request.message,
        json: parseJsonResponse(response),
      );
    } on ApiException catch (error) {
      throw InteractionApiException.fromApiException(error);
    }
  }
}

class InteractionApiException extends ApiException {
  const InteractionApiException({required super.statusCode, super.error});

  factory InteractionApiException.fromApiException(ApiException error) {
    return InteractionApiException(
      statusCode: error.statusCode,
      error: error.error,
    );
  }
}
