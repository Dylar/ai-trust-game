package audit

import "context"

type EventRepository interface {
	Save(ctx context.Context, event Event) error
}

type RequestAnalysisRepository interface {
	Save(ctx context.Context, analysis RequestAnalysis) error
	Get(ctx context.Context, requestID string) (RequestAnalysis, bool, error)
	ListBySession(ctx context.Context, sessionID string) ([]RequestAnalysis, error)
}
