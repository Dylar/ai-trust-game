package audit

import "sync"

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
