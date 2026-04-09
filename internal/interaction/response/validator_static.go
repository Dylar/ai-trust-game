package response

import "strings"

type StaticValidator struct{}

func (StaticValidator) Validate(input ValidatorInput) Result {
	result := input.Result
	if strings.TrimSpace(result.Message) == "" {
		result.Message = "response blocked"
	}
	return result
}
