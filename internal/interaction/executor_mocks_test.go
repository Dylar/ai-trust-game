package interaction

import (
	"errors"

	interactionexecution "github.com/Dylar/ai-trust-game/internal/interaction/execution"
)

var errStubExecutor = errors.New("stub executor failed")

type stubExecutor struct {
	output interactionexecution.ExecutionOutput
	err    error
}

func (executor stubExecutor) build() interactionexecution.Executor {
	return interactionexecution.NewExecutorFunc(func(_ interactionexecution.ExecutionInput) (interactionexecution.ExecutionOutput, error) {
		return executor.output, executor.err
	})
}

type spyExecutor struct {
	output    interactionexecution.ExecutionOutput
	err       error
	lastInput interactionexecution.ExecutionInput
}

func (executor *spyExecutor) build() interactionexecution.Executor {
	return interactionexecution.NewExecutorFunc(func(input interactionexecution.ExecutionInput) (interactionexecution.ExecutionOutput, error) {
		executor.lastInput = input
		return executor.output, executor.err
	})
}
