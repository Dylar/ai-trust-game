package audit

import (
	"context"
	"sync"
)

type AnalyzingSink struct {
	next       Sink
	repo       RequestAnalysisRepository
	mu         sync.Mutex
	eventsByID map[string][]Event
}

func NewAnalyzingSink(next Sink, repo RequestAnalysisRepository) *AnalyzingSink {
	if next == nil {
		next = NewNoopSink()
	}
	if repo == nil {
		repo = NewInMemoryRequestAnalysisRepository()
	}

	return &AnalyzingSink{
		next:       next,
		repo:       repo,
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
	defer s.mu.Unlock()

	events := append(s.eventsByID[requestID], event)
	if !isRequestComplete(event) {
		s.eventsByID[requestID] = events
		return nil
	}

	s.repo.Save(AnalyzeRequest(events))
	delete(s.eventsByID, requestID)
	return nil
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
