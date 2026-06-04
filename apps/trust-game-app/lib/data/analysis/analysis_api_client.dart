import 'package:http/http.dart' as http;

import 'package:app/data/api/api_error.dart';
import 'package:app/data/api/api_transport.dart';
import 'package:app/data/analysis/analysis_dto.dart';

class AnalysisApiClient {
  const AnalysisApiClient({
    required this.httpClient,
    required this.apiBaseUri,
    required this.userId,
  });

  final http.Client httpClient;
  final Uri apiBaseUri;
  final String userId;

  Future<SessionAnalysisResponse> getSessionAnalysis(String sessionId) async {
    try {
      final json = await sendGetJsonRequest(
        httpClient,
        apiBaseUri.resolve('/analysis/session/$sessionId'),
        headers: buildHeaders(userId: userId),
      );
      return SessionAnalysisResponse.fromJson(json);
    } on ApiException catch (error) {
      throw AnalysisApiException.fromApiException(error);
    }
  }

  Future<RequestAnalysisResponse> getRequestAnalysis(String requestId) async {
    try {
      final json = await sendGetJsonRequest(
        httpClient,
        apiBaseUri.resolve('/analysis/request/$requestId'),
        headers: buildHeaders(userId: userId),
      );
      return RequestAnalysisResponse.fromJson(json);
    } on ApiException catch (error) {
      throw AnalysisApiException.fromApiException(error);
    }
  }
}

class AnalysisApiException extends ApiException {
  const AnalysisApiException({required super.statusCode, super.error});

  factory AnalysisApiException.fromApiException(ApiException error) {
    return AnalysisApiException(
      statusCode: error.statusCode,
      error: error.error,
    );
  }
}
