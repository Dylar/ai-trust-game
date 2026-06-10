package user

import (
	"context"
	"sync"
	"time"

	"github.com/google/uuid"
)

type InMemoryRepository struct {
	mu    sync.RWMutex
	users map[string]User
}

func NewInMemoryRepository() *InMemoryRepository {
	return &InMemoryRepository{
		users: make(map[string]User),
	}
}

func (repo *InMemoryRepository) List(context.Context) ([]User, error) {
	repo.mu.RLock()
	defer repo.mu.RUnlock()

	users := make([]User, 0, len(repo.users))
	for _, currentUser := range repo.users {
		users = append(users, currentUser)
	}

	return users, nil
}

func (repo *InMemoryRepository) Create(_ context.Context, displayName string) (User, error) {
	repo.mu.Lock()
	defer repo.mu.Unlock()

	for _, currentUser := range repo.users {
		if currentUser.DisplayName == displayName {
			return User{}, ErrDuplicateDisplayName
		}
	}

	now := time.Now().UTC()
	createdUser := User{
		ID:          uuid.NewString(),
		DisplayName: displayName,
		CreatedAt:   now,
		UpdatedAt:   now,
	}
	repo.users[createdUser.ID] = createdUser

	return createdUser, nil
}

func (repo *InMemoryRepository) Get(_ context.Context, id string) (User, bool, error) {
	repo.mu.RLock()
	defer repo.mu.RUnlock()

	currentUser, ok := repo.users[id]
	return currentUser, ok, nil
}
