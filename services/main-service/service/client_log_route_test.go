package service

import (
	"net/http"
	"testing"

	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/pkg/network"
	"github.com/Dylar/ai-trust-game/tooling/tests"
	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

func TestClientLogRoute(t *testing.T) {
	mux := http.NewServeMux()
	logger := logging.NewConsoleLogger()
	handler := NewClientLogHandler(logger)

	setupClientLogRoute(mux, logger, handler)

	type Given struct {
		requestBody string
	}

	type When struct {
		method string
	}

	type Then struct {
		expectedStatus    int
		expectedErrorCode string
	}

	type Scenario struct {
		name  string
		given Given
		when  When
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN valid client log " +
				"WHEN POST /logs/client " +
				"THEN returns 202",
			given: Given{
				requestBody: `{"level":"info","category":"interaction","message":"message sent"}`,
			},
			when: When{
				method: http.MethodPost,
			},
			then: Then{
				expectedStatus: http.StatusAccepted,
			},
		},
		{
			name: "GIVEN invalid log level " +
				"WHEN POST /logs/client " +
				"THEN returns 400",
			given: Given{
				requestBody: `{"level":"trace","category":"interaction","message":"message sent"}`,
			},
			when: When{
				method: http.MethodPost,
			},
			then: Then{
				expectedStatus:    http.StatusBadRequest,
				expectedErrorCode: errorCodeInvalidClientLogLevel,
			},
		},
		{
			name: "GIVEN missing message " +
				"WHEN POST /logs/client " +
				"THEN returns 400",
			given: Given{
				requestBody: `{"level":"info","category":"interaction","message":""}`,
			},
			when: When{
				method: http.MethodPost,
			},
			then: Then{
				expectedStatus:    http.StatusBadRequest,
				expectedErrorCode: errorCodeMissingClientLogMessage,
			},
		},
		{
			name: "GIVEN invalid json " +
				"WHEN POST /logs/client " +
				"THEN returns 400",
			given: Given{
				requestBody: `{"level":"info","category":"interaction","message":}`,
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
				"WHEN GET /logs/client " +
				"THEN returns 405",
			when: When{
				method: http.MethodGet,
			},
			then: Then{
				expectedStatus:    http.StatusMethodNotAllowed,
				expectedErrorCode: network.ErrorCodeMethodNotAllowed,
			},
		},
	}

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
				"/logs/client",
				headers,
				given.requestBody,
			)

			requestID := rec.Header().Get(network.RequestIDHeader)
			assert.NotEmpty(t, requestID, "expected X-Request-Id header to be set")
			assert.Equal(t, rec.Code, then.expectedStatus, "unexpected status code")

			if then.expectedErrorCode == "" {
				return
			}

			assert.ErrorCode(t, rec.Body.Bytes(), then.expectedErrorCode)
		})
	}
}
