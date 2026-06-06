package service

import (
	"context"
	"net/http"
	"testing"

	"github.com/Dylar/ai-trust-game/services/audit-service/service/audit"
	"github.com/Dylar/ai-trust-game/services/shared/foundation/network"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests"
	"github.com/Dylar/ai-trust-game/services/shared/tooling/tests/assert"
)

type fakeAuditSink struct {
	events []audit.Event
	err    error
}

func (sink *fakeAuditSink) WriteEvent(_ context.Context, event audit.Event) error {
	sink.events = append(sink.events, event)
	return sink.err
}

func TestEventHandler(t *testing.T) {
	type Given struct {
		method string
		body   string
	}

	type Then struct {
		expectedStatus     int
		expectedErrorCode  string
		expectedEventCount int
		expectedSessionID  string
		expectedRequestID  string
		expectedStep       audit.Step
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN valid audit event " +
				"WHEN POST /audit/events " +
				"THEN accepts event and writes it to sink",
			given: Given{
				method: http.MethodPost,
				body:   `{"Type":"interaction","SessionID":"session-123","RequestID":"request-123","Step":"planned"}`,
			},
			then: Then{
				expectedStatus:     http.StatusAccepted,
				expectedEventCount: 1,
				expectedSessionID:  "session-123",
				expectedRequestID:  "request-123",
				expectedStep:       audit.StepPlanned,
			},
		},
		{
			name: "GIVEN invalid JSON " +
				"WHEN POST /audit/events " +
				"THEN returns invalid JSON error",
			given: Given{
				method: http.MethodPost,
				body:   `{`,
			},
			then: Then{
				expectedStatus:    http.StatusBadRequest,
				expectedErrorCode: network.ErrorCodeInvalidJSON,
			},
		},
		{
			name: "GIVEN unsupported method " +
				"WHEN GET /audit/events " +
				"THEN returns method not allowed",
			given: Given{method: http.MethodGet},
			then: Then{
				expectedStatus:    http.StatusMethodNotAllowed,
				expectedErrorCode: network.ErrorCodeMethodNotAllowed,
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			sink := &fakeAuditSink{}
			handler := NewEventHandler(sink)

			rec := tests.ExecuteRequest(
				handler,
				given.method,
				"/audit/events",
				map[string]string{"Content-Type": "application/json"},
				given.body,
			)

			assert.Equal(t, rec.Code, then.expectedStatus, "unexpected status code")
			assert.Equal(t, len(sink.events), then.expectedEventCount, "unexpected event count")

			if then.expectedErrorCode != "" {
				assert.ErrorCode(t, rec.Body.Bytes(), then.expectedErrorCode)
				return
			}

			event := sink.events[0]
			assert.Equal(t, event.SessionID, then.expectedSessionID, "unexpected session id")
			assert.Equal(t, event.RequestID, then.expectedRequestID, "unexpected request id")
			assert.Equal(t, event.Step, then.expectedStep, "unexpected step")
		})
	}
}
