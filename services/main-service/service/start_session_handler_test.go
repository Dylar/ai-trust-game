package service

import (
	"context"
	"github.com/Dylar/ai-trust-game/tooling/tests"
	"testing"

	"github.com/Dylar/ai-trust-game/internal/session"
	"github.com/Dylar/ai-trust-game/pkg/logging"
)

func TestHandleStartSession(t *testing.T) {
	logger := logging.NewConsoleLogger()

	type Given struct {
		role string
		mode string
	}

	type Then struct {
		expectedError error

		expectResponse bool
		expectedRole   string
		expectedMode   string

		expectStoredSession bool
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN valid role and mode " +
				"WHEN handleStartSession is called " +
				"THEN returns session response and stores session",
			given: Given{
				role: "guest",
				mode: "easy",
			},
			then: Then{
				expectedError:       nil,
				expectResponse:      true,
				expectedRole:        "guest",
				expectedMode:        "easy",
				expectStoredSession: true,
			},
		},
		{
			name: "GIVEN invalid role " +
				"WHEN handleStartSession is called " +
				"THEN returns ErrInvalidRole",
			given: Given{
				role: "superadmin",
				mode: "easy",
			},
			then: Then{
				expectedError:       ErrInvalidRole,
				expectResponse:      false,
				expectStoredSession: false,
			},
		},
		{
			name: "GIVEN invalid mode " +
				"WHEN handleStartSession is called " +
				"THEN returns ErrInvalidMode",
			given: Given{
				role: "guest",
				mode: "nightmare",
			},
			then: Then{
				expectedError:       ErrInvalidMode,
				expectResponse:      false,
				expectStoredSession: false,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			sessionRepo := session.NewInMemoryRepository()
			handler := NewStartSessionHandler(logger, sessionRepo)

			ctx := context.Background()

			response, err := handler.handleStartSession(ctx, StartSessionRequest{
				Role: given.role,
				Mode: given.mode,
			})

			tests.AssertErrorIs(t, err, then.expectedError, "unexpected error")

			if !then.expectResponse {
				tests.AssertEmpty(t, response.SessionID, "expected session id empty")
				tests.AssertEmpty(t, response.Role, "expected role empty")
				tests.AssertEmpty(t, response.Mode, "expected mode empty")
				return
			}

			tests.AssertNotEmpty(t, response.SessionID, "expected session id")
			tests.AssertEqual(t, response.Role, then.expectedRole, "unexpected role")
			tests.AssertEqual(t, response.Mode, then.expectedMode, "unexpected mode")

			sess, ok := sessionRepo.Get(response.SessionID)

			if then.expectStoredSession && !ok {
				t.Fatalf("expected session to be stored")
			}

			if then.expectStoredSession {
				tests.AssertEqual(t, string(sess.Role), then.expectedRole, "unexpected stored role")
				tests.AssertEqual(t, string(sess.Mode), then.expectedMode, "unexpected stored mode")
			}
		})
	}
}
