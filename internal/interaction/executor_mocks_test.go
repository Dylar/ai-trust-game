package interaction

import "errors"

var errStubExecutor = errors.New("stub executor failed")

type stubExecutor struct {
	output ExecutionOutput
	err    error
}

func (executor stubExecutor) Execute(_ ExecutionInput) (ExecutionOutput, error) {
	return executor.output, executor.err
}

type spyExecutor struct {
	output    ExecutionOutput
	err       error
	lastInput ExecutionInput
}

func (executor *spyExecutor) Execute(input ExecutionInput) (ExecutionOutput, error) {
	executor.lastInput = input
	return executor.output, executor.err
}
