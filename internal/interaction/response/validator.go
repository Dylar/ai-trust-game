package response

type Validator interface {
	Validate(input ValidatorInput) Result
}

type ValidatorInput struct {
	Response Input
	Result   Result
}
