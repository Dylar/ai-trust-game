package interaction

import (
	"context"
	"sync"
)

type InMemoryRepository struct {
	mu      sync.RWMutex
	records []Record
}

func NewInMemoryRepository() *InMemoryRepository {
	return &InMemoryRepository{}
}

func (repo *InMemoryRepository) Save(_ context.Context, record Record) error {
	repo.mu.Lock()
	defer repo.mu.Unlock()

	repo.records = append(repo.records, record)
	return nil
}

func (repo *InMemoryRepository) List() []Record {
	repo.mu.RLock()
	defer repo.mu.RUnlock()

	records := make([]Record, len(repo.records))
	copy(records, repo.records)
	return records
}
