package audit

import (
	"context"
	"errors"
	"testing"

	"github.com/Dylar/ai-trust-game/tooling/tests/assert"
)

type stubSink struct {
	events []Event
	err    error
}

func (s *stubSink) WriteEvent(_ context.Context, event Event) error {
	if s.err != nil {
		return s.err
	}

	s.events = append(s.events, event)
	return nil
}

func TestAnalyzingSinkWriteEvent(t *testing.T) {
	errSinkFailed := errors.New("sink failed")

	type Given struct {
		events []Event
		sink   Sink
		repo   RequestAnalysisRepository
	}

	type Then struct {
		expectedError          error
		expectedStored         bool
		expectedClassification Classification
		expectedSignals        []string
		expectedEventCount     int
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN successful request events " +
				"WHEN WriteEvent reaches request completion " +
				"THEN stores the analyzed request",
			given: Given{
				events: []Event{
					{RequestID: "request-success", Type: EventTypeInteraction, Step: StepPlanned},
					{RequestID: "request-success", Type: EventTypeInteraction, Step: StepDecided, Outcome: OutcomeAllowed, Suspicion: SuspicionClaimedRoleExceedsTrusted},
					{RequestID: "request-success", Type: EventTypeInteraction, Step: StepStateUpdated, Outcome: OutcomeUpdated},
				},
				sink: &stubSink{},
				repo: NewInMemoryRequestAnalysisRepository(),
			},
			then: Then{
				expectedError:          nil,
				expectedStored:         true,
				expectedClassification: ClassificationSuspicious,
				expectedSignals:        []string{SuspicionClaimedRoleExceedsTrusted},
				expectedEventCount:     3,
			},
		},
		{
			name: "GIVEN planner failure event " +
				"WHEN WriteEvent receives a failed model step " +
				"THEN stores the failed model step analysis",
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
				},
				sink: &stubSink{},
				repo: NewInMemoryRequestAnalysisRepository(),
			},
			then: Then{
				expectedError:          nil,
				expectedStored:         true,
				expectedClassification: ClassificationFailedModelStep,
				expectedSignals:        []string{SuspicionInvalidPlannerOutput, string(FailureKindPlannerOutput)},
				expectedEventCount:     1,
			},
		},
		{
			name: "GIVEN denied request events " +
				"WHEN WriteEvent reaches a denied decision " +
				"THEN stores the analyzed request without waiting for state update",
			given: Given{
				events: []Event{
					{RequestID: "request-denied", Type: EventTypeInteraction, Step: StepPlanned, Suspicion: SuspicionClaimedRoleExceedsTrusted},
					{RequestID: "request-denied", Type: EventTypeInteraction, Step: StepDecided, Outcome: OutcomeDenied},
				},
				sink: &stubSink{},
				repo: NewInMemoryRequestAnalysisRepository(),
			},
			then: Then{
				expectedError:          nil,
				expectedStored:         true,
				expectedClassification: ClassificationSuspicious,
				expectedSignals:        []string{SuspicionClaimedRoleExceedsTrusted},
				expectedEventCount:     2,
			},
		},
		{
			name: "GIVEN underlying sink fails " +
				"WHEN WriteEvent is called " +
				"THEN returns the sink error and stores no analysis",
			given: Given{
				events: []Event{
					{RequestID: "request-error", Type: EventTypeInteraction, Step: StepStateUpdated},
				},
				sink: &stubSink{err: errSinkFailed},
				repo: NewInMemoryRequestAnalysisRepository(),
			},
			then: Then{
				expectedError:      errSinkFailed,
				expectedStored:     false,
				expectedEventCount: 0,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			repo := given.repo.(*InMemoryRequestAnalysisRepository)
			sink := NewAnalyzingSink(given.sink, repo)

			var err error
			for _, event := range given.events {
				err = sink.WriteEvent(context.Background(), event)
				if err != nil {
					break
				}
			}

			assert.ErrorIs(t, err, then.expectedError, "unexpected write error")

			analysis, ok := repo.Get(given.events[0].RequestID)
			assert.Equal(t, ok, then.expectedStored, "unexpected stored analysis state")

			if !then.expectedStored {
				return
			}

			assert.Equal(t, analysis.Classification, then.expectedClassification, "unexpected classification")
			assert.Equal(t, analysis.EventCount, then.expectedEventCount, "unexpected event count")
			assert.Equal(t, len(analysis.Signals), len(then.expectedSignals), "unexpected signal count")
			for index, signal := range then.expectedSignals {
				assert.Equal(t, analysis.Signals[index], signal, "unexpected signal")
			}
		})
	}
}

func TestAnalyzingSinkWriteEvent_SeparatesRequests(t *testing.T) {
	type Given struct {
		events []Event
	}

	type Then struct {
		expectedFirstRequestID       string
		expectedFirstClassification  Classification
		expectedSecondRequestID      string
		expectedSecondClassification Classification
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN events from multiple requests " +
				"WHEN WriteEvent completes each request " +
				"THEN stores separate analyses per request",
			given: Given{
				events: []Event{
					{RequestID: "request-a", Type: EventTypeInteraction, Step: StepPlanned},
					{RequestID: "request-b", Type: EventTypeInteraction, Step: StepPlanned, Suspicion: SuspicionClaimedRoleExceedsTrusted},
					{RequestID: "request-a", Type: EventTypeInteraction, Step: StepStateUpdated, Outcome: OutcomeUpdated},
					{RequestID: "request-b", Type: EventTypeInteraction, Step: StepDecided, Outcome: OutcomeDenied},
				},
			},
			then: Then{
				expectedFirstRequestID:       "request-a",
				expectedFirstClassification:  ClassificationClean,
				expectedSecondRequestID:      "request-b",
				expectedSecondClassification: ClassificationSuspicious,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			repo := NewInMemoryRequestAnalysisRepository()
			sink := NewAnalyzingSink(&stubSink{}, repo)

			for _, event := range given.events {
				err := sink.WriteEvent(context.Background(), event)
				assert.ErrorIs(t, err, nil, "unexpected write error")
			}

			first, ok := repo.Get(then.expectedFirstRequestID)
			assert.Equal(t, ok, true, "expected first analysis")
			assert.Equal(t, first.RequestID, then.expectedFirstRequestID, "unexpected first request id")
			assert.Equal(t, first.Classification, then.expectedFirstClassification, "unexpected first classification")

			second, ok := repo.Get(then.expectedSecondRequestID)
			assert.Equal(t, ok, true, "expected second analysis")
			assert.Equal(t, second.RequestID, then.expectedSecondRequestID, "unexpected second request id")
			assert.Equal(t, second.Classification, then.expectedSecondClassification, "unexpected second classification")
		})
	}
}
