package response

import "strings"

type Validator struct{}

type ValidatorInput struct {
	Response Input
	Result   Result
}

func NewStaticValidator() Validator {
	return Validator{}
}

func (Validator) Validate(input ValidatorInput) Result {
	result := input.Result
	if strings.TrimSpace(result.Message) == "" {
		result.Message = "response blocked"
	}
	return result
}
