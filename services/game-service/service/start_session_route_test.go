package service

import (
	"encoding/json"
	"net/http"
	"testing"

	"github.com/Dylar/ai-trust-game/internal/session"
	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/pkg/network"
	"github.com/Dylar/ai-trust-game/tooling/tests"
	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

func TestStartSessionRoute(t *testing.T) {
	mux := http.NewServeMux()
	logger := logging.NewConsoleLogger()

	sessionRepo := session.NewInMemoryRepository()
	startSessionHandler := NewStartSessionHandler(logger, sessionRepo)

	setupStartSessionRoute(mux, logger, startSessionHandler)

	type Given struct {
		requestBody string
	}

	type When struct {
		method string
	}

	type Then struct {
		expectedStatus    int
		expectedErrorCode string
		expectedRole      string
		expectedMode      string
	}

	type Scenario struct {
		name  string
		given Given
		when  When
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN valid role and mode " +
				"WHEN POST /session/start " +
				"THEN returns 200 and session response",
			given: Given{
				requestBody: `{"role":"guest","mode":"easy"}`,
			},
			when: When{
				method: http.MethodPost,
			},
			then: Then{
				expectedStatus: http.StatusOK,
				expectedRole:   "guest",
				expectedMode:   "easy",
			},
		},
		{
			name: "GIVEN invalid role " +
				"WHEN POST /session/start " +
				"THEN returns 400",
			given: Given{
				requestBody: `{"role":"superadmin","mode":"easy"}`,
			},
			when: When{
				method: http.MethodPost,
			},
			then: Then{
				expectedStatus:    http.StatusBadRequest,
				expectedErrorCode: errorCodeInvalidRole,
			},
		},
		{
			name: "GIVEN invalid mode " +
				"WHEN POST /session/start " +
				"THEN returns 400",
			given: Given{
				requestBody: `{"role":"guest","mode":"nightmare"}`,
			},
			when: When{
				method: http.MethodPost,
			},
			then: Then{
				expectedStatus:    http.StatusBadRequest,
				expectedErrorCode: errorCodeInvalidMode,
			},
		},
		{
			name: "GIVEN invalid json " +
				"WHEN POST /session/start " +
				"THEN returns 400",
			given: Given{
				requestBody: `{"role":"guest","mode":}`,
			},
			when: When{
				method: http.MethodPost,
			},
			then: Then{
				expectedStatus:    http.StatusBadRequest,
				expectedErrorCode: network.ErrorCodeInvalidJSON,
			},
		},
		{
			name: "GIVEN wrong method " +
				"WHEN GET /session/start " +
				"THEN returns 405",
			given: Given{},
			when: When{
				method: http.MethodGet,
			},
			then: Then{
				expectedStatus:    http.StatusMethodNotAllowed,
				expectedErrorCode: network.ErrorCodeMethodNotAllowed,
			},
		},
	}

	path := "/session/start"
	headers := map[string]string{
		"Content-Type": "application/json",
	}
	for _, scenario := range scenarios {
		given := scenario.given
		when := scenario.when
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			rec := tests.ExecuteRequest(
				mux,
				when.method,
				path,
				headers,
				given.requestBody,
			)

			requestID := rec.Header().Get(network.RequestIDHeader)
			assert.NotEmpty(t, requestID, "expected X-Request-Id header to be set")
			assert.Equal(t, rec.Code, then.expectedStatus, "unexpected status code")

			hasExpectedBody := then.expectedRole != "" || then.expectedMode != ""
			if !hasExpectedBody {
				assert.ErrorCode(t, rec.Body.Bytes(), then.expectedErrorCode)
				return
			}

			var response StartSessionResponse
			if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
				t.Fatalf("failed to unmarshal response body: %v", err)
			}

			assert.NotEmpty(t, response.SessionID, "expected session id")
			assert.Equal(t, response.Role, then.expectedRole, "unexpected role")
			assert.Equal(t, response.Mode, then.expectedMode, "unexpected mode")
		})
	}
}
