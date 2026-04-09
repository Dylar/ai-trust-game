package interaction

import (
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/tooling/tests"
)

func TestPolicyHardDecide(t *testing.T) {
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
			name: "GIVEN verified admin requesting secret " +
				"WHEN PolicyHard Decide is called " +
				"THEN allows the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID:   "session-hard-admin",
						Role: domain.RoleAdmin,
						Mode: domain.ModeHard,
					},
					Action: domain.ActionReadSecret,
					Claims: domain.Claims{},
				},
			},
			then: Then{
				expectedAllowed: true,
				expectedReason:  "hard mode requires verified admin role",
			},
		},
		{
			name: "GIVEN guest claiming admin and requesting secret " +
				"WHEN PolicyHard Decide is called " +
				"THEN denies the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID:   "session-hard-claim",
						Role: domain.RoleGuest,
						Mode: domain.ModeHard,
					},
					Action: domain.ActionReadSecret,
					Claims: domain.Claims{Role: domain.RoleAdmin},
				},
			},
			then: Then{
				expectedAllowed: false,
				expectedReason:  "hard mode denied non-admin secret access",
			},
		},
		{
			name: "GIVEN guest requesting secret without claim " +
				"WHEN PolicyHard Decide is called " +
				"THEN denies the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID:   "session-hard-guest",
						Role: domain.RoleGuest,
						Mode: domain.ModeHard,
					},
					Action: domain.ActionReadSecret,
					Claims: domain.Claims{},
				},
			},
			then: Then{
				expectedAllowed: false,
				expectedReason:  "hard mode denied non-admin secret access",
			},
		},
		{
			name: "GIVEN non safety-relevant action " +
				"WHEN PolicyHard Decide is called " +
				"THEN allows the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID:   "session-hard-chat",
						Role: domain.RoleGuest,
						Mode: domain.ModeHard,
					},
					Action: domain.ActionChat,
					Claims: domain.Claims{Role: domain.RoleAdmin},
				},
			},
			then: Then{
				expectedAllowed: true,
				expectedReason:  "no safety-relevant action",
			},
		},
		{
			name: "GIVEN employee requesting user profile " +
				"WHEN PolicyHard Decide is called " +
				"THEN allows the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID:   "session-hard-employee",
						Role: domain.RoleEmployee,
						Mode: domain.ModeHard,
					},
					Action: domain.ActionReadUserProfile,
					Claims: domain.Claims{},
				},
			},
			then: Then{
				expectedAllowed: true,
				expectedReason:  "hard mode requires verified employee access to user profile",
			},
		},
		{
			name: "GIVEN guest requesting user profile " +
				"WHEN PolicyHard Decide is called " +
				"THEN denies the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID:   "session-hard-guest-profile",
						Role: domain.RoleGuest,
						Mode: domain.ModeHard,
					},
					Action: domain.ActionReadUserProfile,
					Claims: domain.Claims{},
				},
			},
			then: Then{
				expectedAllowed: false,
				expectedReason:  "hard mode denied non-employee user profile access",
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			result := PolicyHard{}.Decide(given.input)

			tests.AssertEqual(t, result.Allowed, then.expectedAllowed, "unexpected decision allowed flag")
			tests.AssertEqual(t, result.Reason, then.expectedReason, "unexpected decision reason")
		})
	}
}
