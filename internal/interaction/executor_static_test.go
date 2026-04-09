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
		expectedAction   domain.Action
		expectedSecret   string
		expectedUserInfo string
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
				expectedSecret: "secret data prepared",
			},
		},
		{
			name: "GIVEN get user info action " +
				"WHEN StaticExecutor Execute is called " +
				"THEN returns prepared user info output",
			given: Given{
				input: ExecutionInput{
					Session: domain.Session{ID: "session-user-info"},
					Plan:    Plan{Action: domain.ActionGetUserInfo},
				},
			},
			then: Then{
				expectedAction:   domain.ActionGetUserInfo,
				expectedUserInfo: "user info prepared",
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
			tests.AssertEqual(t, output.UserInfo, then.expectedUserInfo, "unexpected execution user info")
		})
	}
}
