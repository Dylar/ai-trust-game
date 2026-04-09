package execution

import (
	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/interaction/planning"
)

type Executor interface {
	Execute(input ExecutionInput) (ExecutionOutput, error)
}

type ExecutionInput struct {
	Session domain.Session
	Plan    planning.Plan
}

type ExecutionOutput struct {
	Action          domain.Action
	AvailableActions []domain.Action
	Secret          string
	UserProfile     *domain.UserProfile
	PasswordCorrect bool
}
