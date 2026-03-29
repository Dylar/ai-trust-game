package logging

import (
	"context"
	"time"
)

type AuditSink interface {
	WriteEvent(ctx context.Context, event AuditEvent) error
}

type AuditEvent struct {
	Type      string
	RequestID string
	SessionID string
	Route     string
	Method    string
	Role      string
	Mode      string
	Input     string
	Outcome   string
	Suspicion string
	Timestamp time.Time
}
