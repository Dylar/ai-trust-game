package interaction

type ResponseValidator interface {
	Validate(input ResponseValidatorInput) Result
}

type ResponseValidatorInput struct {
	Response ResponseInput
	Result   Result
}
