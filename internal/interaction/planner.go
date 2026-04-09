package interaction

import "github.com/Dylar/ai-trust-game/internal/domain"

type Plan struct {
	Action domain.Action
	Claims domain.Claims
}

type Planner interface {
	Plan(message string) (Plan, error)
}
