import 'dart:convert';

import 'package:http/http.dart' as http;

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
    final response = await httpClient.post(
      apiBaseUri.resolve('/session/start'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'X-User-Id': userId,
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw SessionApiException(response.statusCode);
    }

    return StartSessionResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

class SessionApiException implements Exception {
  const SessionApiException(this.statusCode);

  final int statusCode;
}
