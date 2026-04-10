package interaction

import (
	"errors"

	interactionplanning "github.com/Dylar/ai-trust-game/internal/interaction/planning"
)

var errStubPlanner = errors.New("stub planner failed")

type stubPlanner struct {
	plan interactionplanning.Plan
	err  error
}

func (planner stubPlanner) build() interactionplanning.Planner {
	return interactionplanning.NewPlannerFunc(func(_ string) (interactionplanning.Plan, error) {
		return planner.plan, planner.err
	})
}

type spyPlanner struct {
	plan        interactionplanning.Plan
	err         error
	lastMessage string
}

func (planner *spyPlanner) build() interactionplanning.Planner {
	return interactionplanning.NewPlannerFunc(func(message string) (interactionplanning.Plan, error) {
		planner.lastMessage = message
		return planner.plan, planner.err
	})
}
