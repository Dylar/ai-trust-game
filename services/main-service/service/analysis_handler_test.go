package service

import (
	"errors"
	"testing"

	"github.com/Dylar/ai-trust-game/pkg/audit"
	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

func TestHandleGetRequestAnalysis(t *testing.T) {
	type Given struct {
		requestID string
		repo      requestAnalysisRepository
	}

	type Then struct {
		expectedError          error
		expectedClassification string
		expectedSignalCount    int
		expectedEventCount     int
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN existing request analysis " +
				"WHEN handleGetRequestAnalysis is called " +
				"THEN returns the stored analysis response",
			given: Given{
				requestID: "request-123",
				repo: stubRequestAnalysisRepository{
					analyses: map[string]audit.RequestAnalysis{
						"request-123": {
							RequestID:      "request-123",
							Classification: audit.ClassificationSuspicious,
							Signals:        []string{audit.SuspicionClaimedRoleExceedsTrusted},
							EventCount:     4,
							SuspicionCount: 1,
							ModelFailCount: 0,
						},
					},
				},
			},
			then: Then{
				expectedError:          nil,
				expectedClassification: string(audit.ClassificationSuspicious),
				expectedSignalCount:    1,
				expectedEventCount:     4,
			},
		},
		{
			name: "GIVEN missing request id " +
				"WHEN handleGetRequestAnalysis is called " +
				"THEN returns ErrNoAnalysisRequestID",
			given: Given{
				requestID: "",
				repo:      stubRequestAnalysisRepository{},
			},
			then: Then{
				expectedError: ErrNoAnalysisRequestID,
			},
		},
		{
			name: "GIVEN unknown request id " +
				"WHEN handleGetRequestAnalysis is called " +
				"THEN returns ErrRequestAnalysisNotFound",
			given: Given{
				requestID: "request-missing",
				repo:      stubRequestAnalysisRepository{},
			},
			then: Then{
				expectedError: ErrRequestAnalysisNotFound,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			handler := NewRequestAnalysisHandler(given.repo)

			response, err := handler.handleGetRequestAnalysis(given.requestID)

			assert.ErrorIs(t, err, then.expectedError, "unexpected error")
			if then.expectedError != nil {
				return
			}

			assert.Equal(t, response.RequestID, given.requestID, "unexpected request id")
			assert.Equal(t, response.Classification, then.expectedClassification, "unexpected classification")
			assert.Equal(t, len(response.Signals), then.expectedSignalCount, "unexpected signal count")
			assert.Equal(t, response.EventCount, then.expectedEventCount, "unexpected event count")
		})
	}
}

func TestRequestIDFromPath(t *testing.T) {
	type Given struct {
		path string
	}

	type Then struct {
		expectedRequestID string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN analysis request path " +
				"WHEN requestIDFromPath is called " +
				"THEN returns the request id",
			given: Given{path: "/analysis/request/request-123"},
			then:  Then{expectedRequestID: "request-123"},
		},
		{
			name: "GIVEN unrelated path " +
				"WHEN requestIDFromPath is called " +
				"THEN returns empty string",
			given: Given{path: "/interaction"},
			then:  Then{expectedRequestID: ""},
		},
	}

	for _, scenario := range scenarios {
		t.Run(scenario.name, func(t *testing.T) {
			got := requestIDFromPath(scenario.given.path)
			assert.Equal(t, got, scenario.then.expectedRequestID, "unexpected request id")
		})
	}
}

type stubRequestAnalysisRepository struct {
	analyses map[string]audit.RequestAnalysis
}

func (repo stubRequestAnalysisRepository) Get(requestID string) (audit.RequestAnalysis, bool) {
	analysis, ok := repo.analyses[requestID]
	return analysis, ok
}

func (repo stubRequestAnalysisRepository) Save(audit.RequestAnalysis) {
	panic(errors.New("unexpected save call"))
}
