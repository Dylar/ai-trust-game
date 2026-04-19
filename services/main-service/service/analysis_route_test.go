package service

import (
	"encoding/json"
	"net/http"
	"testing"

	"github.com/Dylar/ai-trust-game/pkg/audit"
	"github.com/Dylar/ai-trust-game/pkg/logging"
	"github.com/Dylar/ai-trust-game/pkg/network"
	"github.com/Dylar/ai-trust-game/tooling/tests"
	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

func TestRequestAnalysisRoute(t *testing.T) {
	mux := http.NewServeMux()
	logger := logging.NewConsoleLogger()
	repo := audit.NewInMemoryRequestAnalysisRepository()
	repo.Save(audit.RequestAnalysis{
		RequestID:      "request-123",
		SessionID:      "session-123",
		Classification: audit.ClassificationSuspicious,
		Signals:        []string{audit.SuspicionClaimedRoleExceedsTrusted},
		EventCount:     4,
		SuspicionCount: 1,
		ModelFailCount: 0,
	})
	handler := NewRequestAnalysisHandler(repo)

	setupRequestAnalysisRoute(mux, logger, handler)
	setupSessionAnalysisRoute(mux, logger, handler)

	type Given struct {
		path string
	}

	type When struct {
		method string
	}

	type Then struct {
		expectedStatus         int
		expectedClassification string
		expectedSignalCount    int
	}

	type Scenario struct {
		name  string
		given Given
		when  When
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN existing request analysis " +
				"WHEN GET /analysis/request/{id} " +
				"THEN returns 200 and the analysis response",
			given: Given{path: "/analysis/request/request-123"},
			when:  When{method: http.MethodGet},
			then: Then{
				expectedStatus:         http.StatusOK,
				expectedClassification: string(audit.ClassificationSuspicious),
				expectedSignalCount:    1,
			},
		},
		{
			name: "GIVEN unknown request analysis " +
				"WHEN GET /analysis/request/{id} " +
				"THEN returns 404",
			given: Given{path: "/analysis/request/request-missing"},
			when:  When{method: http.MethodGet},
			then:  Then{expectedStatus: http.StatusNotFound},
		},
		{
			name: "GIVEN missing request id path " +
				"WHEN GET /analysis/request/ " +
				"THEN returns 400",
			given: Given{path: "/analysis/request/"},
			when:  When{method: http.MethodGet},
			then:  Then{expectedStatus: http.StatusBadRequest},
		},
		{
			name: "GIVEN wrong method " +
				"WHEN POST /analysis/request/{id} " +
				"THEN returns 405",
			given: Given{path: "/analysis/request/request-123"},
			when:  When{method: http.MethodPost},
			then:  Then{expectedStatus: http.StatusMethodNotAllowed},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		when := scenario.when
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			rec := tests.ExecuteRequest(mux, when.method, given.path, nil, "")

			requestID := rec.Header().Get(network.RequestIDHeader)
			assert.NotEmpty(t, requestID, "expected X-Request-Id header to be set")
			assert.Equal(t, rec.Code, then.expectedStatus, "unexpected status code")

			if then.expectedStatus != http.StatusOK {
				return
			}

			var response RequestAnalysisResponse
			if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
				t.Fatalf("failed to unmarshal response body: %v", err)
			}

			assert.Equal(t, response.RequestID, "request-123", "unexpected request id")
			assert.Equal(t, response.SessionID, "session-123", "unexpected session id")
			assert.Equal(t, response.Classification, then.expectedClassification, "unexpected classification")
			assert.Equal(t, len(response.Signals), then.expectedSignalCount, "unexpected signal count")
		})
	}
}

func TestSessionAnalysisRoute(t *testing.T) {
	mux := http.NewServeMux()
	logger := logging.NewConsoleLogger()
	repo := audit.NewInMemoryRequestAnalysisRepository()
	repo.Save(audit.RequestAnalysis{
		RequestID:      "request-123",
		SessionID:      "session-123",
		Classification: audit.ClassificationSuspicious,
		Signals:        []string{audit.SuspicionClaimedRoleExceedsTrusted},
		EventCount:     4,
		SuspicionCount: 1,
		ModelFailCount: 0,
	})
	repo.Save(audit.RequestAnalysis{
		RequestID:      "request-456",
		SessionID:      "session-123",
		Classification: audit.ClassificationFailedModelStep,
		Signals:        []string{audit.SuspicionInvalidPlannerOutput},
		EventCount:     1,
		SuspicionCount: 1,
		ModelFailCount: 1,
	})
	handler := NewRequestAnalysisHandler(repo)

	setupSessionAnalysisRoute(mux, logger, handler)

	type Given struct {
		path string
	}

	type When struct {
		method string
	}

	type Then struct {
		expectedStatus       int
		expectedRequestCount int
		expectedSuspicionSum int
		expectedModelFailSum int
	}

	type Scenario struct {
		name  string
		given Given
		when  When
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN existing session analysis " +
				"WHEN GET /analysis/session/{id} " +
				"THEN returns 200 and the session analysis response",
			given: Given{path: "/analysis/session/session-123"},
			when:  When{method: http.MethodGet},
			then: Then{
				expectedStatus:       http.StatusOK,
				expectedRequestCount: 2,
				expectedSuspicionSum: 2,
				expectedModelFailSum: 1,
			},
		},
		{
			name: "GIVEN unknown session analysis " +
				"WHEN GET /analysis/session/{id} " +
				"THEN returns 404",
			given: Given{path: "/analysis/session/session-missing"},
			when:  When{method: http.MethodGet},
			then:  Then{expectedStatus: http.StatusNotFound},
		},
		{
			name: "GIVEN missing session id path " +
				"WHEN GET /analysis/session/ " +
				"THEN returns 400",
			given: Given{path: "/analysis/session/"},
			when:  When{method: http.MethodGet},
			then:  Then{expectedStatus: http.StatusBadRequest},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		when := scenario.when
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			rec := tests.ExecuteRequest(mux, when.method, given.path, nil, "")

			requestID := rec.Header().Get(network.RequestIDHeader)
			assert.NotEmpty(t, requestID, "expected X-Request-Id header to be set")
			assert.Equal(t, rec.Code, then.expectedStatus, "unexpected status code")

			if then.expectedStatus != http.StatusOK {
				return
			}

			var response SessionAnalysisResponse
			if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
				t.Fatalf("failed to unmarshal response body: %v", err)
			}

			assert.Equal(t, response.SessionID, "session-123", "unexpected session id")
			assert.Equal(t, response.RequestCount, then.expectedRequestCount, "unexpected request count")
			assert.Equal(t, response.SuspicionCount, then.expectedSuspicionSum, "unexpected suspicion sum")
			assert.Equal(t, response.ModelFailCount, then.expectedModelFailSum, "unexpected model failure sum")
			assert.Equal(t, len(response.Requests), then.expectedRequestCount, "unexpected request response count")
		})
	}
}
