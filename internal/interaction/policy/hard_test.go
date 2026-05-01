package policy

import (
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

func TestHardDecide(t *testing.T) {
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
			name: "GIVEN verified admin requesting available actions " +
				"WHEN Hard Decide is called " +
				"THEN allows the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-hard-admin-actions",
						Settings: domain.GameSettings{
							Role: domain.RoleAdmin,
							Mode: domain.ModeHard,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleGuest,
						},
					},
					Action: domain.ActionListAvailableActions,
					Claims: domain.Claims{},
				},
			},
			then: Then{
				expectedAllowed: true,
				expectedReason:  "available actions can always be listed",
			},
		},
		{
			name: "GIVEN guest requesting available actions " +
				"WHEN Hard Decide is called " +
				"THEN allows the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-hard-guest-actions",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeHard,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleAdmin,
						},
					},
					Action: domain.ActionListAvailableActions,
					Claims: domain.Claims{},
				},
			},
			then: Then{
				expectedAllowed: true,
				expectedReason:  "available actions can always be listed",
			},
		},
		{
			name: "GIVEN verified admin requesting secret " +
				"WHEN Hard Decide is called " +
				"THEN allows the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-hard-admin",
						Settings: domain.GameSettings{
							Role: domain.RoleAdmin,
							Mode: domain.ModeHard,
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
				expectedReason:  "hard mode requires verified admin role",
			},
		},
		{
			name: "GIVEN guest with unlocked secret requesting secret " +
				"WHEN Hard Decide is called " +
				"THEN allows the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-hard-unlocked",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeHard,
						},
						State: domain.GameState{
							TrustedRole:    domain.RoleGuest,
							SecretUnlocked: true,
						},
					},
					Action: domain.ActionReadSecret,
					Claims: domain.Claims{},
				},
			},
			then: Then{
				expectedAllowed: true,
				expectedReason:  "hard mode accepts unlocked secret access",
			},
		},
		{
			name: "GIVEN guest claiming admin and requesting secret " +
				"WHEN Hard Decide is called " +
				"THEN denies the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-hard-claim",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeHard,
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
				expectedAllowed: false,
				expectedReason:  "hard mode denied non-admin secret access",
			},
		},
		{
			name: "GIVEN guest requesting secret without claim " +
				"WHEN Hard Decide is called " +
				"THEN denies the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-hard-guest",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeHard,
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
				expectedReason:  "hard mode denied non-admin secret access",
			},
		},
		{
			name: "GIVEN non safety-relevant action " +
				"WHEN Hard Decide is called " +
				"THEN allows the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-hard-chat",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeHard,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleGuest,
						},
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
				"WHEN Hard Decide is called " +
				"THEN allows the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-hard-employee",
						Settings: domain.GameSettings{
							Role: domain.RoleEmployee,
							Mode: domain.ModeHard,
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
				expectedReason:  "hard mode requires verified employee access to user profile",
			},
		},
		{
			name: "GIVEN guest requesting user profile " +
				"WHEN Hard Decide is called " +
				"THEN denies the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-hard-guest-profile",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeHard,
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
				expectedReason:  "hard mode denied non-employee user profile access",
			},
		},
		{
			name: "GIVEN guest with trusted employee role requesting user profile " +
				"WHEN Hard Decide is called " +
				"THEN still denies the interaction",
			given: Given{
				input: DecisionInput{
					Session: domain.Session{
						ID: "session-hard-trusted-employee",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeHard,
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
				expectedAllowed: false,
				expectedReason:  "hard mode denied non-employee user profile access",
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			result := Hard{}.Decide(given.input)

			assert.Equal(t, result.Allowed, then.expectedAllowed, "unexpected decision allowed flag")
			assert.Equal(t, result.Reason, then.expectedReason, "unexpected decision reason")
		})
	}
}
