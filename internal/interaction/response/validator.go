package response

import "strings"

type Validator struct {
	validateFunc func(input ValidatorInput) Result
}

type ValidatorInput struct {
	Response Input
	Result   Result
}

func NewValidatorFunc(validateFunc func(input ValidatorInput) Result) Validator {
	return Validator{validateFunc: validateFunc}
}

func NewStaticValidator() Validator {
	return NewValidatorFunc(func(input ValidatorInput) Result {
		result := input.Result
		if strings.TrimSpace(result.Message) == "" {
			result.Message = "response blocked"
		}
		return result
	})
}

func (validator Validator) Validate(input ValidatorInput) Result {
	if validator.validateFunc != nil {
		return validator.validateFunc(input)
	}
	return input.Result
}
