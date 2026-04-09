package interaction

import "strings"

type StaticResponseValidator struct{}

func (StaticResponseValidator) Validate(input ResponseValidatorInput) Result {
	result := input.Result
	if strings.TrimSpace(result.Message) == "" {
		result.Message = "response blocked"
	}
	return result
}
