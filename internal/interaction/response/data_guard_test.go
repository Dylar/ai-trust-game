package response

import (
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/tooling/tests"
)

func TestNewStaticDataGuardGuard(t *testing.T) {
	type Given struct {
		input Input
	}

	type Then struct {
		expectSecretCleared       bool
		expectProfileCleared      bool
		expectActionsCleared      bool
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
				"WHEN NewStaticDataGuard Guard is called " +
				"THEN keeps only available actions data",
			given: Given{
				input: Input{
					Request: RequestMeta{
						Action: domain.ActionListAvailableActions,
					},
					Payload: Payload{
						AvailableActions: []domain.Action{domain.ActionChat},
						Secret:           "secret",
						UserProfile:      &domain.UserProfile{FirstName: "Clara"},
						PasswordCheck: &PasswordCheck{
							Submitted: true,
							Correct:   true,
						},
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
				"WHEN NewStaticDataGuard Guard is called " +
				"THEN keeps only secret data",
			given: Given{
				input: Input{
					Request: RequestMeta{
						Action: domain.ActionReadSecret,
					},
					Payload: Payload{
						AvailableActions: []domain.Action{domain.ActionChat},
						Secret:           "secret",
						UserProfile:      &domain.UserProfile{FirstName: "Clara"},
						PasswordCheck: &PasswordCheck{
							Submitted: true,
							Correct:   true,
						},
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
			result := NewStaticDataGuard().Guard(given.input)

			tests.AssertEqual(t, result.Payload.Secret == "", then.expectSecretCleared, "unexpected secret clearing")
			tests.AssertEqual(t, result.Payload.UserProfile == nil, then.expectProfileCleared, "unexpected profile clearing")
			tests.AssertEqual(t, len(result.Payload.AvailableActions) == 0, then.expectActionsCleared, "unexpected actions clearing")
			tests.AssertEqual(t, result.Payload.PasswordCheck == nil, then.expectPasswordFlagCleared, "unexpected password payload state")
		})
	}
}
