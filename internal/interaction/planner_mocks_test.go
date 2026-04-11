package interaction

import (
	"context"
	"errors"

	"github.com/Dylar/ai-trust-game/internal/domain"
)

var errStubPlanner = errors.New("stub planner failed")

type stubPlanner struct {
	plan domain.Plan
	err  error
}

func (planner stubPlanner) Plan(_ context.Context, _ string) (domain.Plan, error) {
	return planner.plan, planner.err
}

type spyPlanner struct {
	plan        domain.Plan
	err         error
	lastMessage string
}

func (planner *spyPlanner) Plan(_ context.Context, message string) (domain.Plan, error) {
	planner.lastMessage = message
	return planner.plan, planner.err
}
