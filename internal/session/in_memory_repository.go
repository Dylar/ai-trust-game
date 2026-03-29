package session

import (
	"sync"

	"github.com/Dylar/ai-trust-game/internal/domain"
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

func (s *InMemoryRepository) Save(session domain.Session) {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.sessions[session.ID] = session
}

func (s *InMemoryRepository) Get(id string) (domain.Session, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	session, ok := s.sessions[id]
	return session, ok
}
