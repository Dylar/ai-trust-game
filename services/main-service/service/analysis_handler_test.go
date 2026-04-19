package service

import (
	"errors"
	"sort"
	"testing"
	"time"

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
		expectedSessionID      string
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
							SessionID:      "session-123",
							CompletedAt:    time.Date(2026, 4, 20, 10, 0, 0, 0, time.UTC),
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
				expectedSessionID:      "session-123",
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
			assert.Equal(t, response.SessionID, then.expectedSessionID, "unexpected session id")
			assert.Equal(t, response.CompletedAt.IsZero(), false, "expected completed at")
			assert.Equal(t, response.Classification, then.expectedClassification, "unexpected classification")
			assert.Equal(t, len(response.Signals), then.expectedSignalCount, "unexpected signal count")
			assert.Equal(t, response.EventCount, then.expectedEventCount, "unexpected event count")
		})
	}
}

func TestHandleGetSessionAnalysis(t *testing.T) {
	type Given struct {
		sessionID string
		repo      requestAnalysisRepository
	}

	type Then struct {
		expectedError          error
		expectedClassification string
		expectedRequestCount   int
		expectedSuspicionSum   int
		expectedModelFailSum   int
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN existing session analyses " +
				"WHEN handleGetSessionAnalysis is called " +
				"THEN returns the stored session response",
			given: Given{
				sessionID: "session-123",
				repo: stubRequestAnalysisRepository{
					analyses: map[string]audit.RequestAnalysis{
						"request-1": {
							RequestID:      "request-1",
							SessionID:      "session-123",
							CompletedAt:    time.Date(2026, 4, 20, 10, 0, 0, 0, time.UTC),
							Classification: audit.ClassificationSuspicious,
							Signals:        []string{audit.SuspicionClaimedRoleExceedsTrusted},
							EventCount:     4,
							SuspicionCount: 1,
							ModelFailCount: 0,
						},
						"request-2": {
							RequestID:      "request-2",
							SessionID:      "session-123",
							CompletedAt:    time.Date(2026, 4, 20, 10, 5, 0, 0, time.UTC),
							Classification: audit.ClassificationFailedModelStep,
							Signals:        []string{audit.SuspicionInvalidPlannerOutput},
							EventCount:     1,
							SuspicionCount: 1,
							ModelFailCount: 1,
						},
					},
				},
			},
			then: Then{
				expectedError:          nil,
				expectedClassification: string(audit.ClassificationFailedModelStep),
				expectedRequestCount:   2,
				expectedSuspicionSum:   2,
				expectedModelFailSum:   1,
			},
		},
		{
			name: "GIVEN missing session id " +
				"WHEN handleGetSessionAnalysis is called " +
				"THEN returns ErrNoAnalysisSessionID",
			given: Given{
				sessionID: "",
				repo:      stubRequestAnalysisRepository{},
			},
			then: Then{
				expectedError: ErrNoAnalysisSessionID,
			},
		},
		{
			name: "GIVEN unknown session id " +
				"WHEN handleGetSessionAnalysis is called " +
				"THEN returns ErrSessionAnalysisNotFound",
			given: Given{
				sessionID: "session-missing",
				repo:      stubRequestAnalysisRepository{},
			},
			then: Then{
				expectedError: ErrSessionAnalysisNotFound,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			handler := NewRequestAnalysisHandler(given.repo)

			response, err := handler.handleGetSessionAnalysis(given.sessionID)

			assert.ErrorIs(t, err, then.expectedError, "unexpected error")
			if then.expectedError != nil {
				return
			}

			assert.Equal(t, response.SessionID, given.sessionID, "unexpected session id")
			assert.Equal(t, response.Classification, then.expectedClassification, "unexpected session classification")
			assert.Equal(t, response.RequestCount, then.expectedRequestCount, "unexpected request count")
			assert.Equal(t, response.SuspicionCount, then.expectedSuspicionSum, "unexpected suspicion sum")
			assert.Equal(t, response.ModelFailCount, then.expectedModelFailSum, "unexpected model failure sum")
			assert.Equal(t, len(response.Requests), then.expectedRequestCount, "unexpected request response count")
			assert.Equal(t, response.Requests[0].RequestID, "request-1", "unexpected first timeline request")
			assert.Equal(t, response.Requests[1].RequestID, "request-2", "unexpected second timeline request")
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

func TestSessionIDFromPath(t *testing.T) {
	type Given struct {
		path string
	}

	type Then struct {
		expectedSessionID string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN analysis session path " +
				"WHEN sessionIDFromPath is called " +
				"THEN returns the session id",
			given: Given{path: "/analysis/session/session-123"},
			then:  Then{expectedSessionID: "session-123"},
		},
		{
			name: "GIVEN unrelated path " +
				"WHEN sessionIDFromPath is called " +
				"THEN returns empty string",
			given: Given{path: "/interaction"},
			then:  Then{expectedSessionID: ""},
		},
	}

	for _, scenario := range scenarios {
		t.Run(scenario.name, func(t *testing.T) {
			got := sessionIDFromPath(scenario.given.path)
			assert.Equal(t, got, scenario.then.expectedSessionID, "unexpected session id")
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

func (repo stubRequestAnalysisRepository) ListBySession(sessionID string) []audit.RequestAnalysis {
	analyses := make([]audit.RequestAnalysis, 0)
	for _, analysis := range repo.analyses {
		if analysis.SessionID == sessionID {
			analyses = append(analyses, analysis)
		}
	}

	sort.Slice(analyses, func(i, j int) bool {
		if analyses[i].CompletedAt.Equal(analyses[j].CompletedAt) {
			return analyses[i].RequestID < analyses[j].RequestID
		}
		return analyses[i].CompletedAt.Before(analyses[j].CompletedAt)
	})

	return analyses
}

func (repo stubRequestAnalysisRepository) Save(audit.RequestAnalysis) {
	panic(errors.New("unexpected save call"))
}
