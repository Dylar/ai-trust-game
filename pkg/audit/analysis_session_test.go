package audit

import (
	"testing"

	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

func TestAnalyzeSession(t *testing.T) {
	type Given struct {
		analyses []RequestAnalysis
	}

	type Then struct {
		expectedSessionID      string
		expectedClassification Classification
		expectedRequestCount   int
		expectedSuspicionCount int
		expectedModelFailCount int
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN only clean request analyses " +
				"WHEN AnalyzeSession is called " +
				"THEN returns clean session classification",
			given: Given{
				analyses: []RequestAnalysis{
					{RequestID: "request-1", SessionID: "session-123", Classification: ClassificationClean},
					{RequestID: "request-2", SessionID: "session-123", Classification: ClassificationClean},
				},
			},
			then: Then{
				expectedSessionID:      "session-123",
				expectedClassification: ClassificationClean,
				expectedRequestCount:   2,
				expectedSuspicionCount: 0,
				expectedModelFailCount: 0,
			},
		},
		{
			name: "GIVEN suspicious request analyses without model failures " +
				"WHEN AnalyzeSession is called " +
				"THEN returns suspicious session classification",
			given: Given{
				analyses: []RequestAnalysis{
					{RequestID: "request-1", SessionID: "session-123", Classification: ClassificationClean, SuspicionCount: 0},
					{RequestID: "request-2", SessionID: "session-123", Classification: ClassificationSuspicious, SuspicionCount: 1},
				},
			},
			then: Then{
				expectedSessionID:      "session-123",
				expectedClassification: ClassificationSuspicious,
				expectedRequestCount:   2,
				expectedSuspicionCount: 1,
				expectedModelFailCount: 0,
			},
		},
		{
			name: "GIVEN at least one failed model step request " +
				"WHEN AnalyzeSession is called " +
				"THEN failed model step wins",
			given: Given{
				analyses: []RequestAnalysis{
					{RequestID: "request-1", SessionID: "session-123", Classification: ClassificationSuspicious, SuspicionCount: 1},
					{RequestID: "request-2", SessionID: "session-123", Classification: ClassificationFailedModelStep, SuspicionCount: 1, ModelFailCount: 1},
				},
			},
			then: Then{
				expectedSessionID:      "session-123",
				expectedClassification: ClassificationFailedModelStep,
				expectedRequestCount:   2,
				expectedSuspicionCount: 2,
				expectedModelFailCount: 1,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			session := AnalyzeSession(given.analyses)

			assert.Equal(t, session.SessionID, then.expectedSessionID, "unexpected session id")
			assert.Equal(t, session.Classification, then.expectedClassification, "unexpected session classification")
			assert.Equal(t, session.RequestCount, then.expectedRequestCount, "unexpected request count")
			assert.Equal(t, session.SuspicionCount, then.expectedSuspicionCount, "unexpected suspicion count")
			assert.Equal(t, session.ModelFailCount, then.expectedModelFailCount, "unexpected model failure count")
		})
	}
}
