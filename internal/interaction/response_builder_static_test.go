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
			name: "GIVEN read secret response input " +
				"WHEN StaticResponseBuilder Build is called " +
				"THEN returns system response",
			given: Given{
				input: ResponseInput{
					Interaction: domain.Interaction{
						Session: domain.Session{
							ID:   "session-response",
							Role: domain.RoleGuest,
							Mode: domain.ModeMedium,
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
							ID:   "session-profile",
							Role: domain.RoleEmployee,
							Mode: domain.ModeHard,
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
							ID:   "session-password",
							Role: domain.RoleGuest,
							Mode: domain.ModeEasy,
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
