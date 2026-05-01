package mocks

import (
	"context"

	"github.com/Dylar/ai-trust-game/pkg/audit"
)

type FakeAuditSink struct {
	Events []audit.Event
	Err    error
}

func (f *FakeAuditSink) WriteEvent(_ context.Context, event audit.Event) error {
	f.Events = append(f.Events, event)
	return f.Err
}

func (f *FakeAuditSink) Count() int {
	return len(f.Events)
}

func (f *FakeAuditSink) Last() audit.Event {
	if len(f.Events) == 0 {
		return audit.Event{}
	}
	return f.Events[len(f.Events)-1]
}
