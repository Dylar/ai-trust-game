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
	t.Run("accepts audit events", func(t *testing.T) {
		sink := &fakeAuditSink{}
		handler := NewEventHandler(sink)

		rec := tests.ExecuteRequest(
			handler,
			http.MethodPost,
			"/audit/events",
			map[string]string{"Content-Type": "application/json"},
			`{"Type":"interaction","SessionID":"session-123","RequestID":"request-123","Step":"planned"}`,
		)

		assert.Equal(t, rec.Code, http.StatusAccepted, "unexpected status code")
		assert.Equal(t, len(sink.events), 1, "expected one event to be written")
		assert.Equal(t, sink.events[0].SessionID, "session-123", "unexpected session id")
		assert.Equal(t, sink.events[0].RequestID, "request-123", "unexpected request id")
		assert.Equal(t, sink.events[0].Step, audit.StepPlanned, "unexpected step")
	})

	t.Run("rejects invalid JSON", func(t *testing.T) {
		sink := &fakeAuditSink{}
		handler := NewEventHandler(sink)

		rec := tests.ExecuteRequest(handler, http.MethodPost, "/audit/events", nil, `{`)

		assert.Equal(t, rec.Code, http.StatusBadRequest, "unexpected status code")
		assert.ErrorCode(t, rec.Body.Bytes(), network.ErrorCodeInvalidJSON)
		assert.Equal(t, len(sink.events), 0, "expected no events to be written")
	})

	t.Run("rejects unsupported methods", func(t *testing.T) {
		sink := &fakeAuditSink{}
		handler := NewEventHandler(sink)

		rec := tests.ExecuteRequest(handler, http.MethodGet, "/audit/events", nil, "")

		assert.Equal(t, rec.Code, http.StatusMethodNotAllowed, "unexpected status code")
		assert.ErrorCode(t, rec.Body.Bytes(), network.ErrorCodeMethodNotAllowed)
		assert.Equal(t, len(sink.events), 0, "expected no events to be written")
	})
}
