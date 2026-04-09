package interaction

import (
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/tooling/tests"
)

func TestStaticResponseBuilderBuild(t *testing.T) {
	type Given struct {
		input ResponseInput
	}

	type Then struct {
		expectedMessage string
		expectedSource  Source
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN available actions response input " +
				"WHEN StaticResponseBuilder Build is called " +
				"THEN returns available actions response",
			given: Given{
				input: ResponseInput{
					Interaction: domain.Interaction{
						Session: domain.Session{
							ID: "session-actions",
							Settings: domain.GameSettings{
								Role: domain.RoleAdmin,
								Mode: domain.ModeHard,
							},
						},
					},
					Plan: Plan{
						Action: domain.ActionListAvailableActions,
					},
					Decision: Decision{
						Allowed: true,
						Reason:  "actions access granted",
					},
					Execution: ExecutionOutput{
						Action: domain.ActionListAvailableActions,
						AvailableActions: []domain.Action{
							domain.ActionChat,
							domain.ActionListAvailableActions,
							domain.ActionReadUserProfile,
							domain.ActionSubmitAdminPassword,
							domain.ActionReadSecret,
						},
					},
				},
			},
			then: Then{
				expectedMessage: "Available actions: chat, list_available_actions, read_user_profile, submit_admin_password, read_secret",
				expectedSource:  SourceSystem,
			},
		},
		{
			name: "GIVEN read secret response input " +
				"WHEN StaticResponseBuilder Build is called " +
				"THEN returns system response",
			given: Given{
				input: ResponseInput{
					Interaction: domain.Interaction{
						Session: domain.Session{
							ID: "session-response",
							Settings: domain.GameSettings{
								Role: domain.RoleGuest,
								Mode: domain.ModeMedium,
							},
							State: domain.GameState{
								TrustedRole: domain.RoleGuest,
							},
						},
					},
					Plan: Plan{
						Action: domain.ActionReadSecret,
					},
					Decision: Decision{
						Allowed: true,
						Reason:  "allowed by response builder test",
					},
					Execution: ExecutionOutput{
						Action: domain.ActionReadSecret,
						Secret: "secret data prepared",
					},
				},
			},
			then: Then{
				expectedMessage: "Interacting with session session-response, Role: guest, Mode: medium, Action: read_secret, Reason: allowed by response builder test",
				expectedSource:  SourceSystem,
			},
		},
		{
			name: "GIVEN user profile response input " +
				"WHEN StaticResponseBuilder Build is called " +
				"THEN returns user profile response",
			given: Given{
				input: ResponseInput{
					Interaction: domain.Interaction{
						Session: domain.Session{
							ID: "session-profile",
							Settings: domain.GameSettings{
								Role: domain.RoleEmployee,
								Mode: domain.ModeHard,
							},
							State: domain.GameState{
								TrustedRole: domain.RoleEmployee,
							},
						},
					},
					Plan: Plan{
						Action: domain.ActionReadUserProfile,
					},
					Decision: Decision{
						Allowed: true,
						Reason:  "profile access granted",
					},
					Execution: ExecutionOutput{
						Action: domain.ActionReadUserProfile,
						UserProfile: &domain.UserProfile{
							FirstName:        "Clara",
							LastName:         "Meyer",
							BirthYear:        1988,
							City:             "Hamburg",
							FavoriteIceCream: "Vanille",
							Pet:              "Schaeferhund",
						},
					},
				},
			},
			then: Then{
				expectedMessage: "User profile: Clara Meyer, BirthYear: 1988, City: Hamburg, FavoriteIceCream: Vanille, Pet: Schaeferhund",
				expectedSource:  SourceSystem,
			},
		},
		{
			name: "GIVEN accepted password response input " +
				"WHEN StaticResponseBuilder Build is called " +
				"THEN returns accepted password response",
			given: Given{
				input: ResponseInput{
					Interaction: domain.Interaction{
						Session: domain.Session{
							ID: "session-password",
							Settings: domain.GameSettings{
								Role: domain.RoleGuest,
								Mode: domain.ModeEasy,
							},
							State: domain.GameState{
								TrustedRole: domain.RoleGuest,
							},
						},
					},
					Plan: Plan{
						Action:            domain.ActionSubmitAdminPassword,
						SubmittedPassword: "Schaeferhund88",
					},
					Decision: Decision{
						Allowed: true,
						Reason:  "password submission allowed",
					},
					Execution: ExecutionOutput{
						Action:          domain.ActionSubmitAdminPassword,
						PasswordCorrect: true,
					},
				},
			},
			then: Then{
				expectedMessage: "admin password accepted",
				expectedSource:  SourceSystem,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			result := StaticResponseBuilder{}.Build(given.input)

			tests.AssertEqual(t, result.Message, then.expectedMessage, "unexpected response message")
			tests.AssertEqual(t, result.Source, then.expectedSource, "unexpected response source")
		})
	}
}
