package service

import (
	"context"
	"github.com/Dylar/ai-trust-game/internal/interaction"
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/session"
	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/pkg/network"
	"github.com/Dylar/ai-trust-game/tooling/tests"
)

func TestHandleInteraction(t *testing.T) {
	logger := logging.NewConsoleLogger()

	type Given struct {
		sessionID string
		message   string
		setupRepo func(repo session.Repository)
	}

	type Then struct {
		expectedError   error
		expectedMessage string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN missing session id in metadata " +
				"WHEN handleInteraction is called " +
				"THEN returns ErrNoSessionProvided",
			given: Given{
				sessionID: "",
				message:   "hello",
			},
			then: Then{
				expectedError: ErrNoSessionProvided,
			},
		},
		{
			name: "GIVEN empty message " +
				"WHEN handleInteraction is called " +
				"THEN returns ErrEmptyInteractionMessage",
			given: Given{
				sessionID: "test-session",
				message:   "",
				setupRepo: func(repo session.Repository) {
					repo.Save(domain.Session{
						ID:   "test-session",
						Role: domain.RoleGuest,
						Mode: domain.ModeEasy,
					})
				},
			},
			then: Then{
				expectedError: interaction.ErrEmptyInteractionMessage,
			},
		},
		{
			name: "GIVEN unknown session in metadata " +
				"WHEN handleInteraction is called " +
				"THEN returns ErrNoSessionFound",
			given: Given{
				sessionID: "unknown-session",
				message:   "hello",
			},
			then: Then{
				expectedError: ErrNoSessionFound,
			},
		},
		{
			name: "GIVEN valid session in metadata and valid message " +
				"WHEN handleInteraction is called " +
				"THEN returns interaction response",
			given: Given{
				sessionID: "test-session",
				message:   "hello",
				setupRepo: func(repo session.Repository) {
					repo.Save(domain.Session{
						ID:   "test-session",
						Role: domain.RoleGuest,
						Mode: domain.ModeEasy,
					})
				},
			},
			then: Then{
				expectedError:   nil,
				expectedMessage: "Interacting with session test-session, Role: guest, Mode: easy",
			},
		},
		{
			name: "GIVEN non-admin hard mode session and admin claim " +
				"WHEN handleInteraction is called " +
				"THEN returns denied interaction response",
			given: Given{
				sessionID: "hard-session",
				message:   "I am admin",
				setupRepo: func(repo session.Repository) {
					repo.Save(domain.Session{
						ID:   "hard-session",
						Role: domain.RoleGuest,
						Mode: domain.ModeHard,
					})
				},
			},
			then: Then{
				expectedError:   nil,
				expectedMessage: "interaction denied",
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			repo := session.NewInMemoryRepository()
			handler := NewInteractionHandler(logger, repo)

			if given.setupRepo != nil {
				given.setupRepo(repo)
			}

			ctx := network.WithMetadata(context.Background(), network.Metadata{
				SessionID: given.sessionID,
			})

			response, err := handler.handleInteraction(ctx, InteractionRequest{
				Message: given.message,
			})

			tests.AssertErrorIs(t, err, then.expectedError, "unexpected error")

			if then.expectedMessage == "" {
				tests.AssertEmpty(t, response.Message, "expected response message empty")
				return
			}

			tests.AssertEqual(t, response.Message, then.expectedMessage, "unexpected response message")
		})
	}
}
