package response

import "context"

type stubResponseBuilder struct {
	result Result
	err    error
}

func (builder stubResponseBuilder) Build(_ context.Context, _ Input) (Result, error) {
	return builder.result, builder.err
}

type spyResponseBuilder struct {
	result    Result
	err       error
	lastInput Input
}

func (builder *spyResponseBuilder) Build(_ context.Context, input Input) (Result, error) {
	builder.lastInput = input
	return builder.result, builder.err
}
