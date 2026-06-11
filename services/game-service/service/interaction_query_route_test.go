package service

import (
	"encoding/json"
	"net/http"
	"testing"
	"time"

	"github.com/Dylar/ai-trust-game/services/game-service/service/game"
	"github.com/Dylar/ai-trust-game/services/game-service/service/interaction"
	"github.com/Dylar/ai-trust-game/services/game-service/service/session"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
	"github.com/Dylar/ai-trust-game/services/shared/project/audit"
	"github.com/Dylar/ai-trust-game/services/shared/project/domain"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests/assert"
)

func TestInteractionQueryRoute(t *testing.T) {
	logger := logging.NewConsoleLogger()
	sessionRepo := session.NewInMemoryRepository()
	interactionRepo := interaction.NewInMemoryRepository()
	processor := game.NewStaticProcessor(audit.NewNoopSink(), logger)
	handler := NewInteractionHandler(logger, sessionRepo, processor, interactionRepo)
	mux := http.NewServeMux()
	setupInteractionRoute(mux, logger, handler)

	mustSaveSession(t, sessionRepo, domain.Session{
		ID:     "session-123",
		UserID: "user-123",
		Settings: domain.GameSettings{
			Role: domain.RoleAdmin,
			Mode: domain.ModeHard,
		},
	})
	mustSaveSession(t, sessionRepo, domain.Session{
		ID:     "session-other",
		UserID: "user-123",
		Settings: domain.GameSettings{
			Role: domain.RoleGuest,
			Mode: domain.ModeEasy,
		},
	})
	mustSaveInteraction(t, interactionRepo, interaction.Record{
		ID:           "interaction-2",
		SessionID:    "session-123",
		UserID:       "user-123",
		RequestID:    "request-2",
		UserInput:    "second",
		ResponseText: "answer second",
		CreatedAt:    time.Date(2026, 6, 11, 12, 1, 0, 0, time.UTC),
	})
	mustSaveInteraction(t, interactionRepo, interaction.Record{
		ID:           "interaction-1",
		SessionID:    "session-123",
		UserID:       "user-123",
		RequestID:    "request-1",
		UserInput:    "first",
		ResponseText: "answer first",
		CreatedAt:    time.Date(2026, 6, 11, 12, 0, 0, 0, time.UTC),
	})
	mustSaveInteraction(t, interactionRepo, interaction.Record{
		ID:           "interaction-other-session",
		SessionID:    "session-other",
		UserID:       "user-123",
		RequestID:    "request-other",
		UserInput:    "other",
		ResponseText: "answer other",
		CreatedAt:    time.Date(2026, 6, 11, 12, 2, 0, 0, time.UTC),
	})

	type Given struct {
		userID string
		path   string
	}

	type Then struct {
		expectedStatus         int
		expectedErrorCode      string
		expectedInteractionIDs []string
	}

	scenarios := []struct {
		name  string
		given Given
		then  Then
	}{
		{
			name: "GIVEN existing session interactions " +
				"WHEN GET /interaction/session/{id} " +
				"THEN returns only that user's session interactions oldest first",
			given: Given{
				userID: "user-123",
				path:   "/interaction/session/session-123",
			},
			then: Then{
				expectedStatus:         http.StatusOK,
				expectedInteractionIDs: []string{"interaction-1", "interaction-2"},
			},
		},
		{
			name: "GIVEN session owned by another user " +
				"WHEN GET /interaction/session/{id} " +
				"THEN returns 404",
			given: Given{
				userID: "user-456",
				path:   "/interaction/session/session-123",
			},
			then: Then{
				expectedStatus:    http.StatusNotFound,
				expectedErrorCode: errorCodeSessionNotFound,
			},
		},
	}

	for _, scenario := range scenarios {
		t.Run(scenario.name, func(t *testing.T) {
			rec := tests.ExecuteRequest(
				mux,
				http.MethodGet,
				scenario.given.path,
				map[string]string{network.UserIDHeader: scenario.given.userID},
				"",
			)

			assert.Equal(t, rec.Code, scenario.then.expectedStatus, "unexpected status code")
			if scenario.then.expectedErrorCode != "" {
				assert.ErrorCode(t, rec.Body.Bytes(), scenario.then.expectedErrorCode)
				return
			}

			var response ListInteractionsResponse
			if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
				t.Fatalf("unmarshal response: %v", err)
			}
			if len(response.Interactions) != len(scenario.then.expectedInteractionIDs) {
				t.Fatalf("expected %d interactions, got %d", len(scenario.then.expectedInteractionIDs), len(response.Interactions))
			}
			for index, expectedID := range scenario.then.expectedInteractionIDs {
				assert.Equal(t, response.Interactions[index].InteractionID, expectedID, "unexpected interaction id")
			}
		})
	}
}

func mustSaveInteraction(t *testing.T, repo interaction.Repository, record interaction.Record) {
	t.Helper()
	if err := repo.Save(t.Context(), record); err != nil {
		t.Fatalf("save interaction: %v", err)
	}
}
