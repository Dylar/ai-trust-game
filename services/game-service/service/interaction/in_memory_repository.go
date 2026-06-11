package interaction

import (
	"context"
	"sort"
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

func (repo *InMemoryRepository) ListBySession(_ context.Context, sessionID string) ([]Record, error) {
	repo.mu.RLock()
	defer repo.mu.RUnlock()

	records := []Record{}
	for _, record := range repo.records {
		if record.SessionID == sessionID {
			records = append(records, record)
		}
	}

	sort.Slice(records, func(i, j int) bool {
		if records[i].CreatedAt.Equal(records[j].CreatedAt) {
			return records[i].ID < records[j].ID
		}
		return records[i].CreatedAt.Before(records[j].CreatedAt)
	})

	return records, nil
}
