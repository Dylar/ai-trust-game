import 'package:http/http.dart' as http;

import 'package:app/core/user/selected_user_controller.dart';
import 'package:app/data/api/api_error.dart';
import 'package:app/data/api/api_transport.dart';
import 'package:app/data/analysis/analysis_dto.dart';

abstract interface class AnalysisApi {
  Future<SessionAnalysisResponse> getSessionAnalysis(String sessionId);

  Future<SessionAnalysisResponse> getSessionAnalysisForUser({
    required String userId,
    required String sessionId,
  });

  Future<RequestAnalysisResponse> getRequestAnalysis(String requestId);

  Future<RequestAnalysisResponse> getRequestAnalysisForUser({
    required String userId,
    required String requestId,
  });
}

class AnalysisApiClient implements AnalysisApi {
  const AnalysisApiClient({
    required this.httpClient,
    required this.apiBaseUri,
    required this.selectedUser,
  });

  final http.Client httpClient;
  final Uri apiBaseUri;
  final SelectedUserController selectedUser;

  @override
  Future<SessionAnalysisResponse> getSessionAnalysis(String sessionId) async {
    return getSessionAnalysisForUser(
      userId: selectedUser.requiredUser.id,
      sessionId: sessionId,
    );
  }

  @override
  Future<SessionAnalysisResponse> getSessionAnalysisForUser({
    required String userId,
    required String sessionId,
  }) async {
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

  @override
  Future<RequestAnalysisResponse> getRequestAnalysis(String requestId) async {
    return getRequestAnalysisForUser(
      userId: selectedUser.requiredUser.id,
      requestId: requestId,
    );
  }

  @override
  Future<RequestAnalysisResponse> getRequestAnalysisForUser({
    required String userId,
    required String requestId,
  }) async {
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
