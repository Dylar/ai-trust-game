package session

import (
	"context"

	"github.com/Dylar/ai-trust-game/services/shared/project/domain"
)

type Repository interface {
	Save(ctx context.Context, session domain.Session) error
	Get(ctx context.Context, id string) (domain.Session, bool, error)
	ListByUserID(ctx context.Context, userID string) ([]domain.Session, error)
}
