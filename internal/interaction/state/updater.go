package state

import (
	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/interaction/planning"
)

type StateUpdater interface {
	Update(input StateUpdateInput) (domain.Session, bool)
}

type StateUpdateInput struct {
	Session         domain.Session
	Plan            planning.Plan
	DecisionAllowed bool
	PasswordCorrect bool
}
