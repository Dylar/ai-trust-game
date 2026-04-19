package response

import (
	"testing"

	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

func TestNewValidatorValidate(t *testing.T) {
	type Given struct {
		input ValidationInput
	}

	type Then struct {
		expectedMessage string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN non-empty response message " +
				"WHEN NewValidator Validate is called " +
				"THEN keeps the response",
			given: Given{
				input: ValidationInput{
					Response: Input{},
					Result: Result{
						Message: "hello",
						Source:  SourceSystem,
					},
				},
			},
			then: Then{
				expectedMessage: "hello",
			},
		},
		{
			name: "GIVEN empty response message " +
				"WHEN NewValidator Validate is called " +
				"THEN blocks the response",
			given: Given{
				input: ValidationInput{
					Response: Input{},
					Result: Result{
						Message: "",
						Source:  SourceSystem,
					},
				},
			},
			then: Then{
				expectedMessage: "response blocked",
			},
		},
	}

	for _, scenario := range scenarios {
		t.Run(scenario.name, func(t *testing.T) {
			result := NewValidator().Validate(scenario.given.input)
			assert.Equal(t, result.Message, scenario.then.expectedMessage, "unexpected validated response message")
		})
	}
}
