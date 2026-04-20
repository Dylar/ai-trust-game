package mocks

import (
	"context"

	"github.com/Dylar/ai-trust-game/pkg/audit"
)

type FakeIntentSummarizer struct {
	RequestSummary string
	SessionSummary string
	Err            error
	RequestCalls   int
	SessionCalls   int
}

func (f *FakeIntentSummarizer) SummarizeRequest(context.Context, audit.RequestAnalysis, []audit.Event) (string, error) {
	f.RequestCalls++
	return f.RequestSummary, f.Err
}

func (f *FakeIntentSummarizer) SummarizeSession(context.Context, audit.SessionAnalysis) (string, error) {
	f.SessionCalls++
	return f.SessionSummary, f.Err
}
