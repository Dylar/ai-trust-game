package service

import (
	"encoding/json"
	"net/http"
	"testing"

	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/pkg/network"
	"github.com/Dylar/ai-trust-game/tooling/tests"
	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

func TestHealthRoute(t *testing.T) {
	mux := http.NewServeMux()
	logger := logging.NewConsoleLogger()
	healthHandler := NewHealthHandler()
	setupHealthRoute(mux, logger, healthHandler)

	type When struct {
		method string
	}

	type Then struct {
		expectedStatus    int
		expectedErrorCode string
		expectedBody      HealthResponse
	}

	type Scenario struct {
		name string
		when When
		then Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN health check request WHEN GET /healthz THEN returns ok status",
			when: When{method: http.MethodGet},
			then: Then{
				expectedStatus: http.StatusOK,
				expectedBody:   HealthResponse{Status: "ok"},
			},
		},
		{
			name: "GIVEN wrong method WHEN POST /healthz THEN returns method not allowed",
			when: When{method: http.MethodPost},
			then: Then{
				expectedStatus:    http.StatusMethodNotAllowed,
				expectedErrorCode: network.ErrorCodeMethodNotAllowed,
			},
		},
	}

	for _, scenario := range scenarios {
		scenario := scenario

		t.Run(scenario.name, func(t *testing.T) {
			rec := tests.ExecuteRequest(
				mux,
				scenario.when.method,
				"/healthz",
				nil,
				"",
			)

			assert.Equal(t, rec.Code, scenario.then.expectedStatus, "unexpected status code")

			if scenario.then.expectedStatus != http.StatusOK {
				assert.ErrorCode(t, rec.Body.Bytes(), scenario.then.expectedErrorCode)
				return
			}

			var response HealthResponse
			if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
				t.Fatalf("failed to unmarshal response body: %v", err)
			}

			assert.Equal(t, response.Status, scenario.then.expectedBody.Status, "unexpected health status")
		})
	}
}
