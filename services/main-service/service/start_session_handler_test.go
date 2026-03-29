package service

import (
	"context"
	"errors"
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
			name: "GIVEN valid role and mode WHEN handleStartSession is called THEN returns session response and stores session",
			given: Given{
				role: "customer",
				mode: "easy",
			},
			then: Then{
				expectedError:       nil,
				expectResponse:      true,
				expectedRole:        "customer",
				expectedMode:        "easy",
				expectStoredSession: true,
			},
		},
		{
			name: "GIVEN invalid role WHEN handleStartSession is called THEN returns ErrInvalidRole",
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
			name: "GIVEN invalid mode WHEN handleStartSession is called THEN returns ErrInvalidMode",
			given: Given{
				role: "customer",
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

			if !errors.Is(err, then.expectedError) {
				t.Fatalf("expected error %v, got %v", then.expectedError, err)
			}

			if !then.expectResponse {
				if response.SessionID != "" || response.Role != "" || response.Mode != "" {
					t.Fatalf("expected empty response, got %+v", response)
				}
				return
			}

			if response.SessionID == "" {
				t.Fatalf("expected session id to be set")
			}

			if response.Role != then.expectedRole {
				t.Fatalf("expected role %q, got %q", then.expectedRole, response.Role)
			}

			if response.Mode != then.expectedMode {
				t.Fatalf("expected mode %q, got %q", then.expectedMode, response.Mode)
			}

			sess, ok := sessionRepo.Get(response.SessionID)

			if then.expectStoredSession && !ok {
				t.Fatalf("expected session to be stored")
			}

			if then.expectStoredSession {
				if string(sess.Role) != then.expectedRole {
					t.Fatalf("expected stored role %q, got %q", then.expectedRole, sess.Role)
				}

				if string(sess.Mode) != then.expectedMode {
					t.Fatalf("expected stored mode %q, got %q", then.expectedMode, sess.Mode)
				}
			}
		})
	}
}
