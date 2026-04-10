package response

import "context"

type stubResponseBuilder struct {
	result Result
}

func (builder stubResponseBuilder) Build(_ context.Context, _ Input) Result {
	return builder.result
}

type spyResponseBuilder struct {
	result    Result
	lastInput Input
}

func (builder *spyResponseBuilder) Build(_ context.Context, input Input) Result {
	builder.lastInput = input
	return builder.result
}
