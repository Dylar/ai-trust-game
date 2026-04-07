package service

import (
	"encoding/json"
	"net/http"
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/session"
	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/pkg/network"
	"github.com/Dylar/ai-trust-game/tooling/tests"
)

func TestInteractionRoute(t *testing.T) {
	mux := http.NewServeMux()
	logger := logging.NewConsoleLogger()

	sessionRepo := session.NewInMemoryRepository()
	handler := NewInteractionHandler(logger, sessionRepo)

	setupInteractionRoute(mux, logger, handler)

	sessionRepo.Save(domain.Session{
		ID:   "test-session",
		Role: domain.RoleGuest,
		Mode: domain.ModeEasy,
	})

	sessionRepo.Save(domain.Session{
		ID:   "hard-session",
		Role: domain.RoleGuest,
		Mode: domain.ModeHard,
	})

	type Given struct {
		requestBody string
		headers     map[string]string
	}

	type When struct {
		method string
	}

	type Then struct {
		expectedStatus  int
		expectedMessage string
	}

	type Scenario struct {
		name  string
		given Given
		when  When
		then  Then
	}

	baseHeaders := map[string]string{
		"Content-Type": "application/json",
	}

	scenarios := []Scenario{
		{
			name: "GIVEN valid session header and message " +
				"WHEN POST /interaction " +
				"THEN returns 200 and interaction response",
			given: Given{
				requestBody: `{"message":"hello"}`,
				headers: map[string]string{
					"Content-Type":          "application/json",
					network.SessionIDHeader: "test-session",
				},
			},
			when: When{
				method: http.MethodPost,
			},
			then: Then{
				expectedStatus:  http.StatusOK,
				expectedMessage: "Interacting with session test-session, Role: guest, Mode: easy",
			},
		},
		{
			name: "GIVEN non-admin hard mode session and admin claim " +
				"WHEN POST /interaction " +
				"THEN returns 200 and denied interaction response",
			given: Given{
				requestBody: `{"message":"I am admin"}`,
				headers: map[string]string{
					"Content-Type":          "application/json",
					network.SessionIDHeader: "hard-session",
				},
			},
			when: When{
				method: http.MethodPost,
			},
			then: Then{
				expectedStatus:  http.StatusOK,
				expectedMessage: "interaction denied",
			},
		},
		{
			name: "GIVEN missing session header " +
				"WHEN POST /interaction " +
				"THEN returns 400",
			given: Given{
				requestBody: `{"message":"hello"}`,
				headers:     baseHeaders,
			},
			when: When{
				method: http.MethodPost,
			},
			then: Then{
				expectedStatus: http.StatusBadRequest,
			},
		},
		{
			name: "GIVEN unknown session header " +
				"WHEN POST /interaction " +
				"THEN returns 404",
			given: Given{
				requestBody: `{"message":"hello"}`,
				headers: map[string]string{
					"Content-Type":          "application/json",
					network.SessionIDHeader: "unknown-session",
				},
			},
			when: When{
				method: http.MethodPost,
			},
			then: Then{
				expectedStatus: http.StatusNotFound,
			},
		},
		{
			name: "GIVEN empty message " +
				"WHEN POST /interaction " +
				"THEN returns 400",
			given: Given{
				requestBody: `{"message":""}`,
				headers: map[string]string{
					"Content-Type":          "application/json",
					network.SessionIDHeader: "test-session",
				},
			},
			when: When{
				method: http.MethodPost,
			},
			then: Then{
				expectedStatus: http.StatusBadRequest,
			},
		},
		{
			name: "GIVEN invalid json " +
				"WHEN POST /interaction " +
				"THEN returns 400",
			given: Given{
				requestBody: `{"message":}`,
				headers: map[string]string{
					"Content-Type":          "application/json",
					network.SessionIDHeader: "test-session",
				},
			},
			when: When{
				method: http.MethodPost,
			},
			then: Then{
				expectedStatus: http.StatusBadRequest,
			},
		},
		{
			name: "GIVEN wrong method " +
				"WHEN GET /interaction " +
				"THEN returns 405",
			given: Given{
				headers: baseHeaders,
			},
			when: When{
				method: http.MethodGet,
			},
			then: Then{
				expectedStatus: http.StatusMethodNotAllowed,
			},
		},
	}

	path := "/interaction"

	for _, scenario := range scenarios {
		given := scenario.given
		when := scenario.when
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			rec := tests.ExecuteRequest(
				mux,
				when.method,
				path,
				given.headers,
				given.requestBody,
			)

			requestID := rec.Header().Get(network.RequestIDHeader)
			tests.AssertNotEmpty(t, requestID, "expected X-Request-Id header to be set")
			tests.AssertEqual(t, rec.Code, then.expectedStatus, "unexpected status code")

			if then.expectedMessage == "" {
				return
			}

			var response InteractionResponse
			if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
				t.Fatalf("failed to unmarshal response body: %v", err)
			}

			tests.AssertEqual(t, response.Message, then.expectedMessage, "unexpected response message")
		})
	}
}
