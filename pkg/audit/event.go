package audit

import (
	"context"
	"time"

	"github.com/Dylar/ai-trust-game/pkg/network"
)

type Event struct {
	Type      string
	Timestamp time.Time

	UserID    string
	SessionID string
	RequestID string

	Input     string
	Outcome   string
	Suspicion string
	Reason    string
}

func NewEvent(ctx context.Context, eventType string) Event {
	meta := network.GetMetadata(ctx)

	return Event{
		Type:      eventType,
		Timestamp: time.Now(),
		UserID:    meta.UserID,
		SessionID: meta.SessionID,
		RequestID: meta.RequestID,
	}
}

func NewSuspiciousInputEvent(ctx context.Context, input, suspicion, reason string) Event {
	event := NewEvent(ctx, "suspicious_input")
	event.Input = input
	event.Outcome = "observed"
	event.Suspicion = suspicion
	event.Reason = reason
	return event
}
