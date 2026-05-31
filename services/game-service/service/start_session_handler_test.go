package service

import (
	"context"
	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
	"testing"

	"github.com/Dylar/ai-trust-game/internal/session"
	"github.com/Dylar/ai-trust-game/pkg/logging"
)

func TestHandleStartSession(t *testing.T) {
	logger := logging.NewConsoleLogger()

	type Given struct {
		role domain.Role
		mode domain.Mode
	}

	type Then struct {
		expectedError error

		expectResponse bool
		expectedRole   domain.Role
		expectedMode   domain.Mode

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
				role: domain.RoleGuest,
				mode: "easy",
			},
			then: Then{
				expectedError:       nil,
				expectResponse:      true,
				expectedRole:        domain.RoleGuest,
				expectedMode:        domain.ModeEasy,
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
				Role: string(given.role),
				Mode: string(given.mode),
			})

			assert.ErrorIs(t, err, then.expectedError, "unexpected error")

			if !then.expectResponse {
				assert.Empty(t, response.SessionID, "expected session id empty")
				assert.Empty(t, response.Role, "expected role empty")
				assert.Empty(t, response.Mode, "expected mode empty")
				return
			}

			assert.NotEmpty(t, response.SessionID, "expected session id")
			assert.Equal(t, response.Role, string(then.expectedRole), "unexpected role")
			assert.Equal(t, response.Mode, string(then.expectedMode), "unexpected mode")

			sess, ok := sessionRepo.Get(response.SessionID)

			if then.expectStoredSession && !ok {
				t.Fatalf("expected session to be stored")
			}

			if then.expectStoredSession {
				assert.Equal(t, string(sess.Settings.Role), string(then.expectedRole), "unexpected stored role")
				assert.Equal(t, string(sess.Settings.Mode), string(then.expectedMode), "unexpected stored mode")
				assert.Equal(t, string(sess.State.TrustedRole), string(then.expectedRole), "unexpected initial trusted role")
			}
		})
	}
}
