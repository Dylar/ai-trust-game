package interaction

import "github.com/Dylar/ai-trust-game/internal/domain"

type StateUpdater interface {
	Update(input StateUpdateInput) (domain.Session, bool)
}

type StateUpdateInput struct {
	Session   domain.Session
	Plan      Plan
	Decision  Decision
	Execution ExecutionOutput
}
