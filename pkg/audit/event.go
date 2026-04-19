package audit

import (
	"context"
	"time"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/pkg/network"
)

type EventType string

const (
	EventTypeInteraction     EventType = "interaction"
	EventTypeSuspiciousInput EventType = "suspicious_input"
)

type Step string

const (
	StepPlanned      Step = "planned"
	StepDecided      Step = "decided"
	StepExecuted     Step = "executed"
	StepResponded    Step = "responded"
	StepStateUpdated Step = "state_updated"
)

type Outcome string

const (
	OutcomeObserved      Outcome = "observed"
	OutcomeAllowed       Outcome = "allowed"
	OutcomeDenied        Outcome = "denied"
	OutcomeFailed        Outcome = "failed"
	OutcomeResponseBuilt Outcome = "response_built"
	OutcomeUpdated       Outcome = "updated"
	OutcomeUnchanged     Outcome = "unchanged"
)

type Source string

type FailureKind string

const (
	FailureKindPlannerClient   FailureKind = "planner_client"
	FailureKindPlannerOutput   FailureKind = "planner_output"
	FailureKindResponseBuilder FailureKind = "response_builder"
)

type Event struct {
	Type      EventType
	Timestamp time.Time

	UserID    string
	SessionID string
	RequestID string

	Step       Step
	Action     domain.Action
	Mode       domain.Mode
	Role       domain.Role
	ClaimsRole domain.Role
	Source     Source
	Stage      string

	Input     string
	Outcome   Outcome
	Suspicion string
	Reason    string
	Failure   FailureKind
	HasOutput bool
}

func NewEvent(ctx context.Context, eventType EventType) Event {
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
	event := NewEvent(ctx, EventTypeSuspiciousInput)
	event.Input = input
	event.Outcome = OutcomeObserved
	event.Suspicion = suspicion
	event.Reason = reason
	return event
}

func NewInteractionEvent(ctx context.Context, step Step) Event {
	event := NewEvent(ctx, EventTypeInteraction)
	event.Step = step
	return event
}
