package interaction

type stubResponseBuilder struct {
	result Result
}

func (builder stubResponseBuilder) Build(_ ResponseInput) Result {
	return builder.result
}

type spyResponseBuilder struct {
	result    Result
	lastInput ResponseInput
}

func (builder *spyResponseBuilder) Build(input ResponseInput) Result {
	builder.lastInput = input
	return builder.result
}
