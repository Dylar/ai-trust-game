package service

const (
	// Logging
	errorCodeInvalidClientLogLevel    = "invalid_client_log_level"
	errorCodeMissingClientLogMessage  = "missing_client_log_message"
	errorCodeMissingClientLogCategory = "missing_client_log_category"
	// Domain
	errorCodeInvalidRole     = "invalid_role"
	errorCodeInvalidMode     = "invalid_mode"
	errorCodeMissingSession  = "missing_session"
	errorCodeSessionNotFound = "session_not_found"
	errorCodeEmptyMessage    = "empty_message"
	// Analysis
	errorCodeMissingAnalysisRequest  = "missing_analysis_request"
	errorCodeRequestAnalysisNotFound = "request_analysis_not_found"
	errorCodeMissingAnalysisSession  = "missing_analysis_session"
	errorCodeSessionAnalysisNotFound = "session_analysis_not_found"
)
