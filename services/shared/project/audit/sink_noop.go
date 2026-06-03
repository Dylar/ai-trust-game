package audit

import "context"

type NoopSink struct{}

func NewNoopSink() *NoopSink {
	return &NoopSink{}
}

func (s *NoopSink) WriteEvent(_ context.Context, _ Event) error {
	return nil
}
