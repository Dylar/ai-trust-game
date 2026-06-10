package audit

import (
	"context"
	"sort"
	"sync"
)

type NoopEventRepository struct{}

func NewNoopEventRepository() NoopEventRepository {
	return NoopEventRepository{}
}

func (NoopEventRepository) Save(context.Context, Event) error {
	return nil
}

type InMemoryEventRepository struct {
	mu     sync.RWMutex
	events []Event
}

func NewInMemoryEventRepository() *InMemoryEventRepository {
	return &InMemoryEventRepository{}
}

func (r *InMemoryEventRepository) Save(_ context.Context, event Event) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	r.events = append(r.events, event)
	return nil
}

func (r *InMemoryEventRepository) List() []Event {
	r.mu.RLock()
	defer r.mu.RUnlock()

	events := make([]Event, len(r.events))
	copy(events, r.events)
	return events
}

type InMemoryRequestAnalysisRepository struct {
	mu         sync.RWMutex
	analysesBy map[string]RequestAnalysis
}

func NewInMemoryRequestAnalysisRepository() *InMemoryRequestAnalysisRepository {
	return &InMemoryRequestAnalysisRepository{
		analysesBy: make(map[string]RequestAnalysis),
	}
}

func (r *InMemoryRequestAnalysisRepository) Save(_ context.Context, analysis RequestAnalysis) error {
	r.mu.Lock()
	defer r.mu.Unlock()

	r.analysesBy[analysis.RequestID] = analysis
	return nil
}

func (r *InMemoryRequestAnalysisRepository) Get(_ context.Context, requestID string) (RequestAnalysis, bool, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	analysis, ok := r.analysesBy[requestID]
	return analysis, ok, nil
}

func (r *InMemoryRequestAnalysisRepository) ListBySession(_ context.Context, sessionID string) ([]RequestAnalysis, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	analyses := make([]RequestAnalysis, 0)
	for _, analysis := range r.analysesBy {
		if analysis.SessionID == sessionID {
			analyses = append(analyses, analysis)
		}
	}

	sort.Slice(analyses, func(i, j int) bool {
		if analyses[i].CompletedAt.Equal(analyses[j].CompletedAt) {
			return analyses[i].RequestID < analyses[j].RequestID
		}
		if analyses[i].CompletedAt.IsZero() {
			return false
		}
		if analyses[j].CompletedAt.IsZero() {
			return true
		}
		return analyses[i].CompletedAt.Before(analyses[j].CompletedAt)
	})

	return analyses, nil
}
