package interaction

import (
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/tooling/tests"
)

func TestStaticExecutorExecute(t *testing.T) {
	type Given struct {
		input ExecutionInput
	}

	type Then struct {
		expectedAction          domain.Action
		expectedSecret          string
		expectedPasswordCorrect bool
		expectedUserProfile     *domain.UserProfile
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN read secret action " +
				"WHEN StaticExecutor Execute is called " +
				"THEN returns prepared secret output",
			given: Given{
				input: ExecutionInput{
					Session: domain.Session{ID: "session-secret"},
					Plan:    Plan{Action: domain.ActionReadSecret},
				},
			},
			then: Then{
				expectedAction: domain.ActionReadSecret,
				expectedSecret: adminSecret,
			},
		},
		{
			name: "GIVEN read user profile action " +
				"WHEN StaticExecutor Execute is called " +
				"THEN returns prepared user profile output",
			given: Given{
				input: ExecutionInput{
					Session: domain.Session{ID: "session-user-info"},
					Plan:    Plan{Action: domain.ActionReadUserProfile},
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
				"WHEN StaticExecutor Execute is called " +
				"THEN returns accepted password result",
			given: Given{
				input: ExecutionInput{
					Session: domain.Session{ID: "session-password"},
					Plan: Plan{
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
				"WHEN StaticExecutor Execute is called " +
				"THEN returns action without protected data",
			given: Given{
				input: ExecutionInput{
					Session: domain.Session{ID: "session-chat"},
					Plan:    Plan{Action: domain.ActionChat},
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
			output, err := StaticExecutor{}.Execute(given.input)

			tests.AssertErrorIs(t, err, nil, "unexpected executor error")
			tests.AssertEqual(t, output.Action, then.expectedAction, "unexpected execution action")
			tests.AssertEqual(t, output.Secret, then.expectedSecret, "unexpected execution secret")
			tests.AssertEqual(t, output.PasswordCorrect, then.expectedPasswordCorrect, "unexpected execution password result")

			if then.expectedUserProfile == nil {
				if output.UserProfile != nil {
					t.Fatalf("unexpected execution user profile %+v", *output.UserProfile)
				}
				return
			}

			if output.UserProfile == nil {
				t.Fatalf("expected execution user profile")
			}

			tests.AssertEqual(t, output.UserProfile.FirstName, then.expectedUserProfile.FirstName, "unexpected user profile first name")
			tests.AssertEqual(t, output.UserProfile.LastName, then.expectedUserProfile.LastName, "unexpected user profile last name")
			tests.AssertEqual(t, output.UserProfile.BirthYear, then.expectedUserProfile.BirthYear, "unexpected user profile birth year")
			tests.AssertEqual(t, output.UserProfile.City, then.expectedUserProfile.City, "unexpected user profile city")
			tests.AssertEqual(t, output.UserProfile.FavoriteIceCream, then.expectedUserProfile.FavoriteIceCream, "unexpected user profile favorite ice cream")
			tests.AssertEqual(t, output.UserProfile.Pet, then.expectedUserProfile.Pet, "unexpected user profile pet")
		})
	}
}
