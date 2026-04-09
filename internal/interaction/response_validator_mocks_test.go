package interaction

type stubResponseValidator struct {
	result Result
}

func (validator stubResponseValidator) Validate(_ ResponseValidatorInput) Result {
	return validator.result
}

type spyResponseValidator struct {
	result    Result
	lastInput ResponseValidatorInput
}

func (validator *spyResponseValidator) Validate(input ResponseValidatorInput) Result {
	validator.lastInput = input
	return validator.result
}
