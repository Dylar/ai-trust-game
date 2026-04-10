package response

type stubResponseValidator struct {
	result Result
}

func (validator stubResponseValidator) Validate(_ ValidationInput) Result {
	return validator.result
}

type spyResponseValidator struct {
	result    Result
	lastInput ValidationInput
}

func (validator *spyResponseValidator) Validate(input ValidationInput) Result {
	validator.lastInput = input
	return validator.result
}
