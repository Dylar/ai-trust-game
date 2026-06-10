package session

import (
	"context"
	"sort"
	"sync"

	"github.com/Dylar/ai-trust-game/services/shared/project/domain"
)

type InMemoryRepository struct {
	mu       sync.RWMutex
	sessions map[string]domain.Session
}

func NewInMemoryRepository() *InMemoryRepository {
	return &InMemoryRepository{
		sessions: make(map[string]domain.Session),
	}
}

func (s *InMemoryRepository) Save(_ context.Context, session domain.Session) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.sessions[session.ID] = session
	return nil
}

func (s *InMemoryRepository) Get(_ context.Context, id string) (domain.Session, bool, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	session, ok := s.sessions[id]
	return session, ok, nil
}

func (s *InMemoryRepository) ListByUserID(_ context.Context, userID string) ([]domain.Session, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	sessions := []domain.Session{}
	for _, sess := range s.sessions {
		if sess.UserID == userID {
			sessions = append(sessions, sess)
		}
	}
	sort.Slice(sessions, func(i, j int) bool {
		return sessions[i].UpdatedAt.After(sessions[j].UpdatedAt)
	})

	return sessions, nil
}
