package interaction

import "github.com/Dylar/ai-trust-game/internal/domain"

type Executor interface {
	Execute(input ExecutionInput) (ExecutionOutput, error)
}

type ExecutionInput struct {
	Session domain.Session
	Plan    Plan
}

type ExecutionOutput struct {
	Action          domain.Action
	Secret          string
	UserProfile     *domain.UserProfile
	PasswordCorrect bool
}
