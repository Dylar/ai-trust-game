package interaction

import "errors"

var errStubPlanner = errors.New("stub planner failed")

type stubPlanner struct {
	plan Plan
	err  error
}

func (planner stubPlanner) Plan(_ string) (Plan, error) {
	return planner.plan, planner.err
}

type spyPlanner struct {
	plan        Plan
	err         error
	lastMessage string
}

func (planner *spyPlanner) Plan(message string) (Plan, error) {
	planner.lastMessage = message
	return planner.plan, planner.err
}
