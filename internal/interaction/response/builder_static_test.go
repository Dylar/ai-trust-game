package response

import (
	"context"
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

func TestNewStaticBuilderBuild(t *testing.T) {
	type Given struct {
		input Input
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
				"WHEN NewStaticBuilder Build is called " +
				"THEN returns available actions response",
			given: Given{
				input: Input{
					Session: SessionMeta{
						ID:   "session-actions",
						Role: domain.RoleAdmin,
						Mode: domain.ModeHard,
					},
					Request: RequestMeta{
						Action:           domain.ActionListAvailableActions,
						ResponseLanguage: "en",
					},
					Payload: Payload{
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
				expectedMessage: "You can currently use these actions: chat, list_available_actions, read_user_profile, submit_admin_password, read_secret.",
				expectedSource:  SourceSystem,
			},
		},
		{
			name: "GIVEN read secret response input " +
				"WHEN NewStaticBuilder Build is called " +
				"THEN returns secret response",
			given: Given{
				input: Input{
					Session: SessionMeta{
						ID:   "session-response",
						Role: domain.RoleGuest,
						Mode: domain.ModeMedium,
					},
					Request: RequestMeta{
						Action:           domain.ActionReadSecret,
						ResponseLanguage: "en",
						DecisionReason:   "allowed by response builder test",
					},
					Payload: Payload{
						Secret: "secret data prepared",
					},
				},
			},
			then: Then{
				expectedMessage: "The secret is: secret data prepared",
				expectedSource:  SourceSystem,
			},
		},
		{
			name: "GIVEN user profile response input " +
				"WHEN NewStaticBuilder Build is called " +
				"THEN returns user profile response",
			given: Given{
				input: Input{
					Session: SessionMeta{
						ID:   "session-profile",
						Role: domain.RoleEmployee,
						Mode: domain.ModeHard,
					},
					Request: RequestMeta{
						Action:           domain.ActionReadUserProfile,
						ResponseLanguage: "en",
					},
					Payload: Payload{
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
				expectedMessage: "I found this user profile: Clara Meyer, born 1988, lives in Hamburg, favorite ice cream Vanille, pet Schaeferhund.",
				expectedSource:  SourceSystem,
			},
		},
		{
			name: "GIVEN accepted password response input " +
				"WHEN NewStaticBuilder Build is called " +
				"THEN returns accepted password response",
			given: Given{
				input: Input{
					Session: SessionMeta{
						ID:   "session-password",
						Role: domain.RoleGuest,
						Mode: domain.ModeEasy,
					},
					Request: RequestMeta{
						Action:            domain.ActionSubmitAdminPassword,
						SubmittedPassword: "Schaeferhund88",
						ResponseLanguage:  "en",
					},
					Payload: Payload{
						PasswordCheck: &PasswordCheck{
							Submitted: true,
							Correct:   true,
						},
					},
				},
			},
			then: Then{
				expectedMessage: "That admin password is correct.",
				expectedSource:  SourceSystem,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			result, err := NewStaticBuilder().Build(context.Background(), given.input)

			assert.Equal(t, err, error(nil), "unexpected static builder error")
			assert.Equal(t, result.Message, then.expectedMessage, "unexpected response message")
			assert.Equal(t, result.Source, then.expectedSource, "unexpected response source")
		})
	}
}

func TestNewStaticBuilderBuildUsesRequestedLanguage(t *testing.T) {
	result, err := NewStaticBuilder().Build(context.Background(), Input{
		Request: RequestMeta{
			Action:           domain.ActionReadSecret,
			ResponseLanguage: "de",
		},
		Payload: Payload{
			Secret: "geheimer hinweis",
		},
	})

	assert.Equal(t, err, error(nil), "unexpected static builder error")
	assert.Equal(t, result.Message, "Das Geheimnis ist: geheimer hinweis", "unexpected localized response message")
	assert.Equal(t, result.Source, SourceSystem, "unexpected response source")
}
