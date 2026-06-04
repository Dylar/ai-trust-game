enum ApiErrorCode {
  invalidJson('invalid_json'),
  methodNotAllowed('method_not_allowed'),
  internalError('internal_error'),
  invalidRole('invalid_role'),
  invalidMode('invalid_mode'),
  missingSession('missing_session'),
  sessionNotFound('session_not_found'),
  emptyMessage('empty_message'),
  missingAnalysisRequest('missing_analysis_request'),
  requestAnalysisNotFound('request_analysis_not_found'),
  missingAnalysisSession('missing_analysis_session'),
  sessionAnalysisNotFound('session_analysis_not_found'),
  backendUnreachable('backend_unreachable'),
  requestTimeout('request_timeout');

  const ApiErrorCode(this.value);

  final String value;

  static ApiErrorCode? fromCode(String value) {
    for (final code in values) {
      if (code.value == value) {
        return code;
      }
    }

    return null;
  }
}

class ApiError {
  const ApiError({required this.code});

  final ApiErrorCode code;
}

class ApiException implements Exception {
  const ApiException({this.statusCode, this.error});

  final int? statusCode;
  final ApiError? error;

  ApiErrorCode? get code => error?.code;
}
