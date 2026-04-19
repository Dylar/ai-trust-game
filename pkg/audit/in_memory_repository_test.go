package audit

import (
	"testing"
	"time"

	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

func TestInMemoryRequestAnalysisRepositoryListBySession(t *testing.T) {
	type Given struct {
		analyses  []RequestAnalysis
		sessionID string
	}

	type Then struct {
		expectedCount  int
		expectedFirst  string
		expectedSecond string
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN multiple analyses for one session " +
				"WHEN ListBySession is called " +
				"THEN returns them sorted by completion time",
			given: Given{
				sessionID: "session-123",
				analyses: []RequestAnalysis{
					{
						RequestID:   "request-late",
						SessionID:   "session-123",
						CompletedAt: time.Date(2026, 4, 20, 10, 5, 0, 0, time.UTC),
					},
					{
						RequestID:   "request-early",
						SessionID:   "session-123",
						CompletedAt: time.Date(2026, 4, 20, 10, 0, 0, 0, time.UTC),
					},
					{
						RequestID:   "request-other-session",
						SessionID:   "session-other",
						CompletedAt: time.Date(2026, 4, 20, 9, 0, 0, 0, time.UTC),
					},
				},
			},
			then: Then{
				expectedCount:  2,
				expectedFirst:  "request-early",
				expectedSecond: "request-late",
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			repo := NewInMemoryRequestAnalysisRepository()
			for _, analysis := range given.analyses {
				repo.Save(analysis)
			}

			analyses := repo.ListBySession(given.sessionID)

			assert.Equal(t, len(analyses), then.expectedCount, "unexpected analysis count")
			assert.Equal(t, analyses[0].RequestID, then.expectedFirst, "unexpected first request id")
			assert.Equal(t, analyses[1].RequestID, then.expectedSecond, "unexpected second request id")
		})
	}
}
