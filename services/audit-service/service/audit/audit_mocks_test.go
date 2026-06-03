package audit

import "context"

type fakeSink struct {
	events []Event
	err    error
}

func (f *fakeSink) WriteEvent(_ context.Context, event Event) error {
	if f.err != nil {
		return f.err
	}

	f.events = append(f.events, event)
	return nil
}

type fakeIntentSummarizer struct {
	requestSummary string
	sessionSummary string
	err            error
	requestCalls   int
	sessionCalls   int
}

func (f *fakeIntentSummarizer) SummarizeRequest(context.Context, RequestAnalysis, []Event) (string, error) {
	f.requestCalls++
	return f.requestSummary, f.err
}

func (f *fakeIntentSummarizer) SummarizeSession(context.Context, SessionAnalysis) (string, error) {
	f.sessionCalls++
	return f.sessionSummary, f.err
}
