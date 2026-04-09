package interaction

import (
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/tooling/tests"
)

func TestPolicyMediumDecide(t *testing.T) {
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
				"WHEN PolicyMedium Decide is called " +
				"THEN allows the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-medium-admin",
						Settings: domain.GameSettings{
							Role: domain.RoleAdmin,
							Mode: domain.ModeMedium,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleAdmin,
						},
						},
					Action: domain.ActionReadSecret,
					Claims: domain.Claims{},
				},
			},
			then: Then{
				expectedAllowed: true,
				expectedReason:  "medium mode accepts verified admin role",
			},
		},
		{
			name: "GIVEN guest claiming admin and requesting secret " +
				"WHEN PolicyMedium Decide is called " +
				"THEN allows the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-medium-claim",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeMedium,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleGuest,
						},
						},
					Action: domain.ActionReadSecret,
					Claims: domain.Claims{Role: domain.RoleAdmin},
				},
			},
			then: Then{
				expectedAllowed: true,
				expectedReason:  "medium mode trusts admin claim",
			},
		},
		{
			name: "GIVEN guest requesting secret without admin claim " +
				"WHEN PolicyMedium Decide is called " +
				"THEN denies the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-medium-denied",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeMedium,
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
				expectedAllowed: false,
				expectedReason:  "medium mode denied non-admin secret access",
			},
		},
		{
			name: "GIVEN non safety-relevant action " +
				"WHEN PolicyMedium Decide is called " +
				"THEN allows the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-medium-chat",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeMedium,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleGuest,
						},
						},
					Action: domain.ActionChat,
					Claims: domain.Claims{},
				},
			},
			then: Then{
				expectedAllowed: true,
				expectedReason:  "no safety-relevant action",
			},
		},
		{
			name: "GIVEN employee requesting user profile " +
				"WHEN PolicyMedium Decide is called " +
				"THEN allows the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-medium-employee",
						Settings: domain.GameSettings{
							Role: domain.RoleEmployee,
							Mode: domain.ModeMedium,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleGuest,
						},
						},
					Action: domain.ActionReadUserProfile,
					Claims: domain.Claims{},
				},
			},
			then: Then{
				expectedAllowed: true,
				expectedReason:  "medium mode accepts verified employee access to user profile",
			},
		},
		{
			name: "GIVEN guest with trusted employee role requesting user profile " +
				"WHEN PolicyMedium Decide is called " +
				"THEN allows the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-medium-trusted-employee",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeMedium,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleEmployee,
						},
						},
					Action: domain.ActionReadUserProfile,
					Claims: domain.Claims{},
				},
			},
			then: Then{
				expectedAllowed: true,
				expectedReason:  "medium mode accepts trusted role access to user profile",
			},
		},
		{
			name: "GIVEN guest requesting user profile " +
				"WHEN PolicyMedium Decide is called " +
				"THEN denies the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-medium-guest-profile",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeMedium,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleGuest,
						},
						},
					Action: domain.ActionReadUserProfile,
					Claims: domain.Claims{},
				},
			},
			then: Then{
				expectedAllowed: false,
				expectedReason:  "medium mode denied non-employee user profile access",
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			result := PolicyMedium{}.Decide(given.input)

			tests.AssertEqual(t, result.Allowed, then.expectedAllowed, "unexpected decision allowed flag")
			tests.AssertEqual(t, result.Reason, then.expectedReason, "unexpected decision reason")
		})
	}
}
