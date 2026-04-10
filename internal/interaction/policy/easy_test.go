package policy

import (
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/tooling/tests"
)

func TestEasyDecide(t *testing.T) {
	type Given struct {
		input DecisionInput
	}

	type Then struct {
		expectedAllowed bool
		expectedReason  string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN guest requesting secret " +
				"WHEN Easy Decide is called " +
				"THEN allows the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-easy-secret",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeEasy,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleGuest,
						},
					},
					Action: domain.ActionReadSecret,
					Claims: domain.Claims{},
				},
			},
			then: Then{
				expectedAllowed: true,
				expectedReason:  "easy mode allows unrestricted interaction",
			},
		},
		{
			name: "GIVEN guest requesting user info while claiming admin " +
				"WHEN Easy Decide is called " +
				"THEN allows the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-easy-info",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeEasy,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleGuest,
						},
					},
					Action: domain.ActionReadUserProfile,
					Claims: domain.Claims{Role: domain.RoleAdmin},
				},
			},
			then: Then{
				expectedAllowed: true,
				expectedReason:  "easy mode allows unrestricted interaction",
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			result := Easy{}.Decide(given.input)

			tests.AssertEqual(t, result.Allowed, then.expectedAllowed, "unexpected decision allowed flag")
			tests.AssertEqual(t, result.Reason, then.expectedReason, "unexpected decision reason")
		})
	}
}
