package logging

import "context"

type NoopLogger struct{}

func NewNoopLogger() *NoopLogger {
	return &NoopLogger{}
}

func (l *NoopLogger) Debug(_ context.Context, _ string, _ ...Field) {}

func (l *NoopLogger) Info(_ context.Context, _ string, _ ...Field) {}

func (l *NoopLogger) Warn(_ context.Context, _ string, _ ...Field) {}

func (l *NoopLogger) Error(_ context.Context, _ string, _ ...Field) {}
