package audit

type RequestAnalysisRepository interface {
	Save(analysis RequestAnalysis)
	Get(requestID string) (RequestAnalysis, bool)
	ListBySession(sessionID string) []RequestAnalysis
}
