package response

type stubResponseBuilder struct {
	result Result
}

func (builder stubResponseBuilder) Build(_ Input) Result {
	return builder.result
}

type spyResponseBuilder struct {
	result    Result
	lastInput Input
}

func (builder *spyResponseBuilder) Build(input Input) Result {
	builder.lastInput = input
	return builder.result
}
