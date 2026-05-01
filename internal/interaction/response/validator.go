package response

import "strings"

type Validator struct{}

type ValidationInput struct {
	Response Input
	Result   Result
}

func NewValidator() Validator {
	return Validator{}
}

func (Validator) Validate(input ValidationInput) Result {
	result := input.Result
	if strings.TrimSpace(result.Message) == "" {
		result.Message = "response blocked"
	}
	return result
}
