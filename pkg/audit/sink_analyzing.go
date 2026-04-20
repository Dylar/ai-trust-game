package audit

import (
	"context"
	"sync"
)

type AnalyzingSink struct {
	next       Sink
	repo       RequestAnalysisRepository
	summarizer IntentSummarizer
	mu         sync.Mutex
	eventsByID map[string][]Event
}

func NewAnalyzingSink(next Sink, repo RequestAnalysisRepository) *AnalyzingSink {
	return NewAnalyzingSinkWithSummarizer(next, repo, NoopIntentSummarizer{})
}

func NewAnalyzingSinkWithSummarizer(next Sink, repo RequestAnalysisRepository, summarizer IntentSummarizer) *AnalyzingSink {
	if next == nil {
		next = NewNoopSink()
	}
	if repo == nil {
		repo = NewInMemoryRequestAnalysisRepository()
	}
	if summarizer == nil {
		summarizer = NoopIntentSummarizer{}
	}

	return &AnalyzingSink{
		next:       next,
		repo:       repo,
		summarizer: summarizer,
		eventsByID: make(map[string][]Event),
	}
}

func (s *AnalyzingSink) WriteEvent(ctx context.Context, event Event) error {
	if err := s.next.WriteEvent(ctx, event); err != nil {
		return err
	}

	requestID := event.RequestID
	if requestID == "" {
		return nil
	}

	s.mu.Lock()
	events := append(s.eventsByID[requestID], event)
	if !isRequestComplete(event) {
		s.eventsByID[requestID] = events
		s.mu.Unlock()
		return nil
	}
	delete(s.eventsByID, requestID)
	s.mu.Unlock()

	analysis := AnalyzeRequest(events)
	summarized := s.summarizeRequest(ctx, analysis, events)
	s.repo.Save(summarized)
	return nil
}

func (s *AnalyzingSink) summarizeRequest(ctx context.Context, analysis RequestAnalysis, events []Event) RequestAnalysis {
	if s.summarizer == nil {
		return analysis
	}
	if !shouldSummarizeIntent(analysis) {
		return analysis
	}

	summary, err := s.summarizer.SummarizeRequest(ctx, analysis, events)
	if err != nil {
		return analysis
	}

	analysis.IntentSummary = summary
	return analysis
}

func shouldSummarizeIntent(analysis RequestAnalysis) bool {
	return analysis.Classification == ClassificationSuspicious ||
		analysis.Classification == ClassificationFailedModelStep
}

func isRequestComplete(event Event) bool {
	if event.Step == StepStateUpdated {
		return true
	}
	if event.Step == StepDecided && event.Outcome == OutcomeDenied {
		return true
	}

	return isModelStepFailure(event)
}
