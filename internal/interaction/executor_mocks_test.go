package interaction

import (
	"errors"

	interactionexecution "github.com/Dylar/ai-trust-game/internal/interaction/execution"
)

var errStubExecutor = errors.New("stub executor failed")

type stubExecutor struct {
	output interactionexecution.Output
	err    error
}

func (executor stubExecutor) Execute(_ interactionexecution.Input) (interactionexecution.Output, error) {
	return executor.output, executor.err
}

type spyExecutor struct {
	output    interactionexecution.Output
	err       error
	lastInput interactionexecution.Input
}

func (executor *spyExecutor) Execute(input interactionexecution.Input) (interactionexecution.Output, error) {
	executor.lastInput = input
	return executor.output, executor.err
}
