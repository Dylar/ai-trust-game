package llm

import "context"

type Client interface {
	Generate(ctx context.Context, request Request) (Response, error)
}

type Request struct {
	Stage        Stage
	SystemPrompt string
	UserPrompt   string
}

type Stage string

const (
	StagePlanner         Stage = "planner"
	StageResponseBuilder Stage = "response_builder"
	StageAuditAnalysis   Stage = "audit_analysis"
)

type Response struct {
	Text string
}
