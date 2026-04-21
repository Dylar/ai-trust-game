import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:app/data/analysis/analysis_dto.dart';

class AnalysisApiClient {
  const AnalysisApiClient({required this.httpClient, required this.apiBaseUri});

  final http.Client httpClient;
  final Uri apiBaseUri;

  Future<SessionAnalysisResponse> getSessionAnalysis(String sessionId) async {
    final response = await httpClient.get(
      apiBaseUri.resolve('/analysis/session/$sessionId'),
    );

    if (response.statusCode != 200) {
      throw AnalysisApiException(response.statusCode);
    }

    return SessionAnalysisResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<RequestAnalysisResponse> getRequestAnalysis(String requestId) async {
    final response = await httpClient.get(
      apiBaseUri.resolve('/analysis/request/$requestId'),
    );

    if (response.statusCode != 200) {
      throw AnalysisApiException(response.statusCode);
    }

    return RequestAnalysisResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

class AnalysisApiException implements Exception {
  const AnalysisApiException(this.statusCode);

  final int statusCode;
}
