package interaction

import (
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/tooling/tests"
)

func TestStaticResponseDataGuardGuard(t *testing.T) {
	type Given struct {
		input ResponseInput
	}

	type Then struct {
		expectSecretCleared      bool
		expectProfileCleared     bool
		expectActionsCleared     bool
		expectPasswordFlagCleared bool
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN available actions response input " +
				"WHEN StaticResponseDataGuard Guard is called " +
				"THEN keeps only available actions data",
			given: Given{
				input: ResponseInput{
					Plan: Plan{Action: domain.ActionListAvailableActions},
					Execution: ExecutionOutput{
						AvailableActions: []domain.Action{domain.ActionChat},
						Secret:           "secret",
						UserProfile:      &domain.UserProfile{FirstName: "Clara"},
						PasswordCorrect:  true,
					},
				},
			},
			then: Then{
				expectSecretCleared:       true,
				expectProfileCleared:      true,
				expectActionsCleared:      false,
				expectPasswordFlagCleared: true,
			},
		},
		{
			name: "GIVEN read secret response input " +
				"WHEN StaticResponseDataGuard Guard is called " +
				"THEN keeps only secret data",
			given: Given{
				input: ResponseInput{
					Plan: Plan{Action: domain.ActionReadSecret},
					Execution: ExecutionOutput{
						AvailableActions: []domain.Action{domain.ActionChat},
						Secret:           "secret",
						UserProfile:      &domain.UserProfile{FirstName: "Clara"},
						PasswordCorrect:  true,
					},
				},
			},
			then: Then{
				expectSecretCleared:       false,
				expectProfileCleared:      true,
				expectActionsCleared:      true,
				expectPasswordFlagCleared: true,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			result := StaticResponseDataGuard{}.Guard(given.input)

			tests.AssertEqual(t, result.Execution.Secret == "", then.expectSecretCleared, "unexpected secret clearing")
			tests.AssertEqual(t, result.Execution.UserProfile == nil, then.expectProfileCleared, "unexpected profile clearing")
			tests.AssertEqual(t, len(result.Execution.AvailableActions) == 0, then.expectActionsCleared, "unexpected actions clearing")
			tests.AssertEqual(t, result.Execution.PasswordCorrect, !then.expectPasswordFlagCleared && given.input.Execution.PasswordCorrect, "unexpected password flag state")
		})
	}
}
