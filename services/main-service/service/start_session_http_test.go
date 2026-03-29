package service

import (
	"encoding/json"
	"net/http"
	"testing"

	"github.com/Dylar/ai-trust-game/internal/session"
	"github.com/Dylar/ai-trust-game/internal/tests"
	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/pkg/network"
)

func TestStartSessionRoute(t *testing.T) {
	mux := http.NewServeMux()
	logger := logging.NewConsoleLogger()

	sessionRepo := session.NewInMemoryRepository()
	startSessionHandler := NewStartSessionHandler(logger, sessionRepo)

	setupStartSessionRoute(mux, logger, startSessionHandler)

	type Given struct {
		requestBody string
		headers     map[string]string
	}

	type When struct {
		method string
		path   string
	}

	type Then struct {
		expectedStatus int
		expectBody     bool

		expectedRole string
		expectedMode string
	}

	type Scenario struct {
		name  string
		given Given
		when  When
		then  Then
	}

	headers := map[string]string{
		"Content-Type": "application/json",
	}

	scenarios := []Scenario{
		{
			name: "GIVEN valid role and mode " +
				"WHEN POST /session/start " +
				"THEN returns 200 and session response",
			given: Given{
				requestBody: `{"role":"customer","mode":"easy"}`,
				headers:     headers,
			},
			when: When{
				method: http.MethodPost,
				path:   "/session/start",
			},
			then: Then{
				expectedStatus: http.StatusOK,
				expectBody:     true,
				expectedRole:   "customer",
				expectedMode:   "easy",
			},
		},
		{
			name: "GIVEN invalid role " +
				"WHEN POST /session/start " +
				"THEN returns 400",
			given: Given{
				requestBody: `{"role":"superadmin","mode":"easy"}`,
				headers:     headers,
			},
			when: When{
				method: http.MethodPost,
				path:   "/session/start",
			},
			then: Then{
				expectedStatus: http.StatusBadRequest,
				expectBody:     false,
			},
		},
		{
			name: "GIVEN invalid mode " +
				"WHEN POST /session/start " +
				"THEN returns 400",
			given: Given{
				requestBody: `{"role":"customer","mode":"nightmare"}`,
				headers:     headers,
			},
			when: When{
				method: http.MethodPost,
				path:   "/session/start",
			},
			then: Then{
				expectedStatus: http.StatusBadRequest,
				expectBody:     false,
			},
		},
		{
			name: "GIVEN invalid json " +
				"WHEN POST /session/start " +
				"THEN returns 400",
			given: Given{
				requestBody: `{"role":"customer","mode":}`,
				headers:     headers,
			},
			when: When{
				method: http.MethodPost,
				path:   "/session/start",
			},
			then: Then{
				expectedStatus: http.StatusBadRequest,
				expectBody:     false,
			},
		},
		{
			name: "GIVEN wrong method " +
				"WHEN GET /session/start " +
				"THEN returns 405",
			given: Given{
				headers: headers,
			},
			when: When{
				method: http.MethodGet,
				path:   "/session/start",
			},
			then: Then{
				expectedStatus: http.StatusMethodNotAllowed,
				expectBody:     false,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		when := scenario.when
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			rec := tests.ExecuteRequest(
				mux,
				when.method,
				when.path,
				given.headers,
				given.requestBody,
			)

			requestID := rec.Header().Get(network.RequestIDHeader)
			if requestID == "" {
				t.Fatalf("expected X-Request-Id header to be set")
			}

			if rec.Code != then.expectedStatus {
				t.Fatalf("expected status %d, got %d", then.expectedStatus, rec.Code)
			}

			if !then.expectBody {
				return
			}

			var response StartSessionResponse
			if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
				t.Fatalf("failed to unmarshal response body: %v", err)
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
		})
	}
}
