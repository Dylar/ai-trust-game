package execution

import (
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

func TestNewExecutorExecute(t *testing.T) {
	type Given struct {
		input Input
	}

	type Then struct {
		expectedAction           domain.Action
		expectedAvailableActions []domain.Action
		expectedSecret           string
		expectedPasswordCorrect  bool
		expectedUserProfile      *domain.UserProfile
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN admin listing available actions in hard mode " +
				"WHEN NewExecutor Execute is called " +
				"THEN returns full available actions output",
			given: Given{
				input: Input{
					Session: domain.Session{
						ID: "session-actions-admin",
						Settings: domain.GameSettings{
							Role: domain.RoleAdmin,
							Mode: domain.ModeHard,
						},
					},
					Plan: domain.Plan{Action: domain.ActionListAvailableActions},
				},
			},
			then: Then{
				expectedAction: domain.ActionListAvailableActions,
				expectedAvailableActions: []domain.Action{
					domain.ActionChat,
					domain.ActionSubmitAdminPassword,
					domain.ActionListAvailableActions,
					domain.ActionReadUserProfile,
					domain.ActionReadSecret,
				},
			},
		},
		{
			name: "GIVEN guest listing available actions in hard mode " +
				"WHEN NewExecutor Execute is called " +
				"THEN returns restricted available actions output",
			given: Given{
				input: Input{
					Session: domain.Session{
						ID: "session-actions-guest",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeHard,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleAdmin,
						},
					},
					Plan: domain.Plan{Action: domain.ActionListAvailableActions},
				},
			},
			then: Then{
				expectedAction: domain.ActionListAvailableActions,
				expectedAvailableActions: []domain.Action{
					domain.ActionChat,
					domain.ActionSubmitAdminPassword,
					domain.ActionListAvailableActions,
				},
			},
		},
		{
			name: "GIVEN guest with trusted employee role listing available actions in medium mode " +
				"WHEN NewExecutor Execute is called " +
				"THEN returns employee-level available actions output",
			given: Given{
				input: Input{
					Session: domain.Session{
						ID: "session-actions-medium-trusted",
						Settings: domain.GameSettings{
							Role: domain.RoleGuest,
							Mode: domain.ModeMedium,
						},
						State: domain.GameState{
							TrustedRole: domain.RoleEmployee,
						},
					},
					Plan: domain.Plan{Action: domain.ActionListAvailableActions},
				},
			},
			then: Then{
				expectedAction: domain.ActionListAvailableActions,
				expectedAvailableActions: []domain.Action{
					domain.ActionChat,
					domain.ActionSubmitAdminPassword,
					domain.ActionListAvailableActions,
					domain.ActionReadUserProfile,
				},
			},
		},
		{
			name: "GIVEN read secret action " +
				"WHEN NewExecutor Execute is called " +
				"THEN returns prepared secret output",
			given: Given{
				input: Input{
					Session: domain.Session{ID: "session-secret"},
					Plan:    domain.Plan{Action: domain.ActionReadSecret},
				},
			},
			then: Then{
				expectedAction: domain.ActionReadSecret,
				expectedSecret: adminSecret,
			},
		},
		{
			name: "GIVEN read user profile action " +
				"WHEN NewExecutor Execute is called " +
				"THEN returns prepared user profile output",
			given: Given{
				input: Input{
					Session: domain.Session{ID: "session-user-info"},
					Plan:    domain.Plan{Action: domain.ActionReadUserProfile},
				},
			},
			then: Then{
				expectedAction: domain.ActionReadUserProfile,
				expectedUserProfile: &domain.UserProfile{
					FirstName:        "Clara",
					LastName:         "Meyer",
					BirthYear:        1988,
					City:             "Hamburg",
					FavoriteIceCream: "Vanille",
					Pet:              "Schaeferhund",
				},
			},
		},
		{
			name: "GIVEN correct admin password submission " +
				"WHEN NewExecutor Execute is called " +
				"THEN returns accepted password result",
			given: Given{
				input: Input{
					Session: domain.Session{ID: "session-password"},
					Plan: domain.Plan{
						Action:            domain.ActionSubmitAdminPassword,
						SubmittedPassword: "Schaeferhund88",
					},
				},
			},
			then: Then{
				expectedAction:          domain.ActionSubmitAdminPassword,
				expectedPasswordCorrect: true,
			},
		},
		{
			name: "GIVEN chat action " +
				"WHEN NewExecutor Execute is called " +
				"THEN returns action without protected data",
			given: Given{
				input: Input{
					Session: domain.Session{ID: "session-chat"},
					Plan:    domain.Plan{Action: domain.ActionChat},
				},
			},
			then: Then{
				expectedAction: domain.ActionChat,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			output, err := NewExecutor().Execute(given.input)

			assert.ErrorIs(t, err, nil, "unexpected executor error")
			assert.Equal(t, output.Action, then.expectedAction, "unexpected execution action")
			assert.Equal(t, len(output.AvailableActions), len(then.expectedAvailableActions), "unexpected available actions length")
			for index, action := range then.expectedAvailableActions {
				assert.Equal(t, output.AvailableActions[index], action, "unexpected available action")
			}
			assert.Equal(t, output.Secret, then.expectedSecret, "unexpected execution secret")
			assert.Equal(t, output.PasswordCorrect, then.expectedPasswordCorrect, "unexpected execution password result")

			if then.expectedUserProfile == nil {
				if output.UserProfile != nil {
					t.Fatalf("unexpected execution user profile %+v", *output.UserProfile)
				}
				return
			}

			if output.UserProfile == nil {
				t.Fatalf("expected execution user profile")
			}

			assert.Equal(t, output.UserProfile.FirstName, then.expectedUserProfile.FirstName, "unexpected user profile first name")
			assert.Equal(t, output.UserProfile.LastName, then.expectedUserProfile.LastName, "unexpected user profile last name")
			assert.Equal(t, output.UserProfile.BirthYear, then.expectedUserProfile.BirthYear, "unexpected user profile birth year")
			assert.Equal(t, output.UserProfile.City, then.expectedUserProfile.City, "unexpected user profile city")
			assert.Equal(t, output.UserProfile.FavoriteIceCream, then.expectedUserProfile.FavoriteIceCream, "unexpected user profile favorite ice cream")
			assert.Equal(t, output.UserProfile.Pet, then.expectedUserProfile.Pet, "unexpected user profile pet")
		})
	}
}
