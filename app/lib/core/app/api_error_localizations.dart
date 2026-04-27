import 'package:app/data/api/api_error.dart';
import 'package:app/l10n/app_localizations.dart';

extension ApiErrorLocalizations on AppLocalizations {
  String apiErrorDescription(ApiErrorCode? code) {
    return switch (code) {
      ApiErrorCode.invalidJson => apiErrorInvalidJson,
      ApiErrorCode.methodNotAllowed => apiErrorMethodNotAllowed,
      ApiErrorCode.internalError => apiErrorInternal,
      ApiErrorCode.invalidRole => apiErrorInvalidRole,
      ApiErrorCode.invalidMode => apiErrorInvalidMode,
      ApiErrorCode.missingSession => apiErrorMissingSession,
      ApiErrorCode.sessionNotFound => apiErrorSessionNotFound,
      ApiErrorCode.emptyMessage => apiErrorEmptyMessage,
      ApiErrorCode.missingAnalysisRequest => apiErrorMissingAnalysisRequest,
      ApiErrorCode.requestAnalysisNotFound => apiErrorRequestAnalysisNotFound,
      ApiErrorCode.missingAnalysisSession => apiErrorMissingAnalysisSession,
      ApiErrorCode.sessionAnalysisNotFound => apiErrorSessionAnalysisNotFound,
      ApiErrorCode.backendUnreachable => apiErrorBackendUnreachable,
      ApiErrorCode.requestTimeout => apiErrorRequestTimeout,
      _ => apiErrorUnknown,
    };
  }
}
