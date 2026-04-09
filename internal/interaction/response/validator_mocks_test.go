package response

type stubResponseValidator struct {
	result Result
}

func (validator stubResponseValidator) Validate(_ ValidatorInput) Result {
	return validator.result
}

type spyResponseValidator struct {
	result    Result
	lastInput ValidatorInput
}

func (validator *spyResponseValidator) Validate(input ValidatorInput) Result {
	validator.lastInput = input
	return validator.result
}
