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

func (planner stubPlanner) Plan(_ string) (interactionplanning.Plan, error) {
	return planner.plan, planner.err
}

type spyPlanner struct {
	plan        interactionplanning.Plan
	err         error
	lastMessage string
}

func (planner *spyPlanner) Plan(message string) (interactionplanning.Plan, error) {
	planner.lastMessage = message
	return planner.plan, planner.err
}
