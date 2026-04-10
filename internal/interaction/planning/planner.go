package planning

import "github.com/Dylar/ai-trust-game/internal/domain"

type Planner interface {
	Plan(message string) (Plan, error)
}

type Plan struct {
	Action            domain.Action
	Claims            domain.Claims
	SubmittedPassword string
}
