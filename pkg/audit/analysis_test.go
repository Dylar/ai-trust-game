package audit

import (
	"testing"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

func TestAnalyzeRequest(t *testing.T) {
	type Given struct {
		events []Event
	}

	type Then struct {
		expectedRequestID      string
		expectedClassification Classification
		expectedSignals        []string
		expectedEventCount     int
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
			name: "GIVEN ordinary interaction events " +
				"WHEN AnalyzeRequest is called " +
				"THEN returns clean classification",
			given: Given{
				events: []Event{
					{RequestID: "request-clean", Type: EventTypeInteraction, Step: StepPlanned},
					{RequestID: "request-clean", Type: EventTypeInteraction, Step: StepDecided, Outcome: OutcomeAllowed},
				},
			},
			then: Then{
				expectedRequestID:      "request-clean",
				expectedClassification: ClassificationClean,
				expectedSignals:        []string{},
				expectedEventCount:     2,
				expectedSuspicionCount: 0,
				expectedModelFailCount: 0,
			},
		},
		{
			name: "GIVEN suspicious interaction events " +
				"WHEN AnalyzeRequest is called " +
				"THEN returns suspicious classification",
			given: Given{
				events: []Event{
					{
						RequestID: "request-suspicious",
						Type:      EventTypeInteraction,
						Step:      StepPlanned,
						Action:    domain.ActionReadSecret,
						Suspicion: SuspicionClaimedRoleExceedsTrusted,
					},
					{
						RequestID: "request-suspicious",
						Type:      EventTypeInteraction,
						Step:      StepResponded,
						Outcome:   OutcomeResponseBuilt,
					},
				},
			},
			then: Then{
				expectedRequestID:      "request-suspicious",
				expectedClassification: ClassificationSuspicious,
				expectedSignals:        []string{SuspicionClaimedRoleExceedsTrusted},
				expectedEventCount:     2,
				expectedSuspicionCount: 1,
				expectedModelFailCount: 0,
			},
		},
		{
			name: "GIVEN model step failure and suspicion " +
				"WHEN AnalyzeRequest is called " +
				"THEN model failure classification wins",
			given: Given{
				events: []Event{
					{
						RequestID: "request-failed",
						Type:      EventTypeInteraction,
						Step:      StepPlanned,
						Stage:     "planner",
						Outcome:   OutcomeFailed,
						Failure:   FailureKindPlannerOutput,
						Suspicion: SuspicionInvalidPlannerOutput,
					},
					{
						RequestID: "request-failed",
						Type:      EventTypeInteraction,
						Step:      StepResponded,
						Suspicion: SuspicionClaimedRoleExceedsTrusted,
					},
				},
			},
			then: Then{
				expectedRequestID:      "request-failed",
				expectedClassification: ClassificationFailedModelStep,
				expectedSignals: []string{
					SuspicionClaimedRoleExceedsTrusted,
					SuspicionInvalidPlannerOutput,
					string(FailureKindPlannerOutput),
				},
				expectedEventCount:     2,
				expectedSuspicionCount: 2,
				expectedModelFailCount: 1,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			analysis := AnalyzeRequest(given.events)

			assert.Equal(t, analysis.RequestID, then.expectedRequestID, "unexpected request id")
			assert.Equal(t, analysis.Classification, then.expectedClassification, "unexpected classification")
			assert.Equal(t, analysis.EventCount, then.expectedEventCount, "unexpected event count")
			assert.Equal(t, analysis.SuspicionCount, then.expectedSuspicionCount, "unexpected suspicion count")
			assert.Equal(t, analysis.ModelFailCount, then.expectedModelFailCount, "unexpected model failure count")
			assert.Equal(t, len(analysis.Signals), len(then.expectedSignals), "unexpected signal count")

			for index, expectedSignal := range then.expectedSignals {
				assert.Equal(t, analysis.Signals[index], expectedSignal, "unexpected signal")
			}
		})
	}
}

func TestAnalyzeRequests(t *testing.T) {
	type Given struct {
		events []Event
	}

	type Then struct {
		expectedCount           int
		expectedFirstRequestID  string
		expectedFirstClass      Classification
		expectedSecondRequestID string
		expectedSecondClass     Classification
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN events from multiple requests " +
				"WHEN AnalyzeRequests is called " +
				"THEN returns one ordered analysis per request",
			given: Given{
				events: []Event{
					{RequestID: "request-a", Type: EventTypeInteraction, Step: StepPlanned},
					{RequestID: "request-b", Type: EventTypeInteraction, Step: StepPlanned, Suspicion: SuspicionClaimedRoleExceedsTrusted},
					{RequestID: "request-a", Type: EventTypeInteraction, Step: StepResponded, Outcome: OutcomeResponseBuilt},
				},
			},
			then: Then{
				expectedCount:           2,
				expectedFirstRequestID:  "request-a",
				expectedFirstClass:      ClassificationClean,
				expectedSecondRequestID: "request-b",
				expectedSecondClass:     ClassificationSuspicious,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			analyses := AnalyzeRequests(given.events)

			assert.Equal(t, len(analyses), then.expectedCount, "unexpected analysis count")
			assert.Equal(t, analyses[0].RequestID, then.expectedFirstRequestID, "unexpected first request id")
			assert.Equal(t, analyses[0].Classification, then.expectedFirstClass, "unexpected first classification")
			assert.Equal(t, analyses[1].RequestID, then.expectedSecondRequestID, "unexpected second request id")
			assert.Equal(t, analyses[1].Classification, then.expectedSecondClass, "unexpected second classification")
		})
	}
}
