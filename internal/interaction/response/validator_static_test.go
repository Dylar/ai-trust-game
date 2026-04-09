package response

import (
	"testing"

	"github.com/Dylar/ai-trust-game/tooling/tests"
)

func TestStaticValidatorValidate(t *testing.T) {
	type Given struct {
		input ValidatorInput
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
				"WHEN StaticResponseValidator Validate is called " +
				"THEN keeps the response",
			given: Given{
				input: ValidatorInput{
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
				"WHEN StaticResponseValidator Validate is called " +
				"THEN blocks the response",
			given: Given{
				input: ValidatorInput{
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
			result := StaticValidator{}.Validate(scenario.given.input)
			tests.AssertEqual(t, result.Message, scenario.then.expectedMessage, "unexpected validated response message")
		})
	}
}
