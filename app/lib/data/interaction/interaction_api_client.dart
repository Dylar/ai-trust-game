import 'dart:convert';

import 'package:http/http.dart' as http;

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
    final response = await httpClient.post(
      apiBaseUri.resolve('/interaction'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'X-Session-Id': request.sessionId,
        'X-User-Id': userId,
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw InteractionApiException(response.statusCode);
    }

    final requestId =
        response.headers['x-request-id'] ??
        'local-${DateTime.now().microsecondsSinceEpoch}';

    return InteractionResponse.fromBackend(
      sessionId: request.sessionId,
      requestId: requestId,
      requestMessage: request.message,
      json: jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

class InteractionApiException implements Exception {
  const InteractionApiException(this.statusCode);

  final int statusCode;
}
