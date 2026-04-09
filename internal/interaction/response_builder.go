package interaction

import "github.com/Dylar/ai-trust-game/internal/domain"

type ResponseBuilder interface {
	Build(input ResponseInput) Result
}

type ResponseInput struct {
	Interaction domain.Interaction
	Plan        Plan
	Decision    Decision
	Execution   ExecutionOutput
}

type Result struct {
	Message        string
	Source         Source
	UpdatedSession *domain.Session
}
