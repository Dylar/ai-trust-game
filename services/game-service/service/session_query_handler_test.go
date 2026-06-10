package service

import (
	"encoding/json"
	"net/http"
	"testing"
	"time"

	"github.com/Dylar/ai-trust-game/services/game-service/service/session"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/logging"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
	"github.com/Dylar/ai-trust-game/services/shared/project/domain"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests/assert"
)

func TestSessionQueryRoute(t *testing.T) {
	mux := http.NewServeMux()
	logger := logging.NewConsoleLogger()
	sessionRepo := session.NewInMemoryRepository()
	sessionQueryHandler := NewSessionQueryHandler(sessionRepo)

	setupSessionQueryRoute(mux, logger, sessionQueryHandler)

	olderTime := time.Date(2026, 6, 10, 10, 0, 0, 0, time.UTC)
	newerTime := olderTime.Add(time.Hour)
	mustSaveSession(t, sessionRepo, domain.Session{
		ID:        "session-old",
		UserID:    "user-123",
		CreatedAt: olderTime,
		UpdatedAt: olderTime,
		Settings: domain.GameSettings{
			Role: domain.RoleGuest,
			Mode: domain.ModeEasy,
		},
		State: domain.GameState{
			TrustedRole:    domain.RoleGuest,
			SecretUnlocked: false,
		},
	})
	mustSaveSession(t, sessionRepo, domain.Session{
		ID:        "session-new",
		UserID:    "user-123",
		CreatedAt: newerTime,
		UpdatedAt: newerTime,
		Settings: domain.GameSettings{
			Role: domain.RoleAdmin,
			Mode: domain.ModeHard,
		},
		State: domain.GameState{
			TrustedRole:    domain.RoleAdmin,
			SecretUnlocked: true,
		},
	})
	mustSaveSession(t, sessionRepo, domain.Session{
		ID:        "session-other-user",
		UserID:    "user-456",
		CreatedAt: newerTime,
		UpdatedAt: newerTime,
		Settings: domain.GameSettings{
			Role: domain.RoleGuest,
			Mode: domain.ModeMedium,
		},
		State: domain.GameState{
			TrustedRole: domain.RoleGuest,
		},
	})

	type Given struct {
		headers map[string]string
		path    string
	}

	type Then struct {
		expectedStatus      int
		expectedErrorCode   string
		expectedSessionID   string
		expectedSessionIDs  []string
		expectedSecretState bool
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN existing sessions for user " +
				"WHEN GET /session/list " +
				"THEN returns only that user's sessions newest first",
			given: Given{
				path: "/session/list",
				headers: map[string]string{
					network.UserIDHeader: "user-123",
				},
			},
			then: Then{
				expectedStatus:     http.StatusOK,
				expectedSessionIDs: []string{"session-new", "session-old"},
			},
		},
		{
			name: "GIVEN existing session owned by user " +
				"WHEN GET /session/{id} " +
				"THEN returns session detail",
			given: Given{
				path: "/session/session-new",
				headers: map[string]string{
					network.UserIDHeader: "user-123",
				},
			},
			then: Then{
				expectedStatus:      http.StatusOK,
				expectedSessionID:   "session-new",
				expectedSecretState: true,
			},
		},
		{
			name: "GIVEN session owned by another user " +
				"WHEN GET /session/{id} " +
				"THEN returns 404",
			given: Given{
				path: "/session/session-other-user",
				headers: map[string]string{
					network.UserIDHeader: "user-123",
				},
			},
			then: Then{
				expectedStatus:    http.StatusNotFound,
				expectedErrorCode: errorCodeSessionNotFound,
			},
		},
		{
			name: "GIVEN missing user id " +
				"WHEN GET /session/list " +
				"THEN returns 400",
			given: Given{
				path: "/session/list",
			},
			then: Then{
				expectedStatus:    http.StatusBadRequest,
				expectedErrorCode: errorCodeMissingUser,
			},
		},
		{
			name: "GIVEN wrong method " +
				"WHEN POST /session/list " +
				"THEN returns 405",
			given: Given{
				path: "/session/list",
				headers: map[string]string{
					network.UserIDHeader: "user-123",
				},
			},
			then: Then{
				expectedStatus:    http.StatusMethodNotAllowed,
				expectedErrorCode: network.ErrorCodeMethodNotAllowed,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			method := http.MethodGet
			if then.expectedErrorCode == network.ErrorCodeMethodNotAllowed {
				method = http.MethodPost
			}

			rec := tests.ExecuteRequest(mux, method, given.path, given.headers, "")

			assert.Equal(t, rec.Code, then.expectedStatus, "unexpected status code")
			if then.expectedErrorCode != "" {
				assert.ErrorCode(t, rec.Body.Bytes(), then.expectedErrorCode)
				return
			}

			if len(then.expectedSessionIDs) > 0 {
				var response ListSessionsResponse
				if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
					t.Fatalf("unmarshal list response: %v", err)
				}
				if len(response.Sessions) != len(then.expectedSessionIDs) {
					t.Fatalf("expected %d sessions, got %d", len(then.expectedSessionIDs), len(response.Sessions))
				}
				for index, expectedSessionID := range then.expectedSessionIDs {
					assert.Equal(t, response.Sessions[index].SessionID, expectedSessionID, "unexpected session id")
				}
				return
			}

			var response SessionDetailResponse
			if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
				t.Fatalf("unmarshal detail response: %v", err)
			}
			assert.Equal(t, response.SessionID, then.expectedSessionID, "unexpected session id")
			assert.Equal(t, response.SecretUnlocked, then.expectedSecretState, "unexpected secret state")
		})
	}
}
