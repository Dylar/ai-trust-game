package audit

import (
	"sort"
	"sync"
)

type InMemoryRequestAnalysisRepository struct {
	mu         sync.RWMutex
	analysesBy map[string]RequestAnalysis
}

func NewInMemoryRequestAnalysisRepository() *InMemoryRequestAnalysisRepository {
	return &InMemoryRequestAnalysisRepository{
		analysesBy: make(map[string]RequestAnalysis),
	}
}

func (r *InMemoryRequestAnalysisRepository) Save(analysis RequestAnalysis) {
	r.mu.Lock()
	defer r.mu.Unlock()

	r.analysesBy[analysis.RequestID] = analysis
}

func (r *InMemoryRequestAnalysisRepository) Get(requestID string) (RequestAnalysis, bool) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	analysis, ok := r.analysesBy[requestID]
	return analysis, ok
}

func (r *InMemoryRequestAnalysisRepository) ListBySession(sessionID string) []RequestAnalysis {
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

	return analyses
}
