package audit

import (
	"context"

	sharedaudit "github.com/Dylar/ai-trust-game/services/shared/project/audit"
)

type EventType = sharedaudit.EventType

const (
	EventTypeInteraction     = sharedaudit.EventTypeInteraction
	EventTypeSuspiciousInput = sharedaudit.EventTypeSuspiciousInput
)

const (
	SuspicionPossiblePromptInjection   = sharedaudit.SuspicionPossiblePromptInjection
	SuspicionClaimedRoleExceedsTrusted = sharedaudit.SuspicionClaimedRoleExceedsTrusted
	SuspicionInvalidPlannerOutput      = sharedaudit.SuspicionInvalidPlannerOutput
)

type Step = sharedaudit.Step

const (
	StepPlanned      = sharedaudit.StepPlanned
	StepDecided      = sharedaudit.StepDecided
	StepExecuted     = sharedaudit.StepExecuted
	StepResponded    = sharedaudit.StepResponded
	StepStateUpdated = sharedaudit.StepStateUpdated
)

type Outcome = sharedaudit.Outcome

const (
	OutcomeObserved      = sharedaudit.OutcomeObserved
	OutcomeAllowed       = sharedaudit.OutcomeAllowed
	OutcomeDenied        = sharedaudit.OutcomeDenied
	OutcomeFailed        = sharedaudit.OutcomeFailed
	OutcomeResponseBuilt = sharedaudit.OutcomeResponseBuilt
	OutcomeUpdated       = sharedaudit.OutcomeUpdated
	OutcomeUnchanged     = sharedaudit.OutcomeUnchanged
)

type Source = sharedaudit.Source

type FailureKind = sharedaudit.FailureKind

const (
	FailureKindPlannerClient   = sharedaudit.FailureKindPlannerClient
	FailureKindPlannerOutput   = sharedaudit.FailureKindPlannerOutput
	FailureKindResponseBuilder = sharedaudit.FailureKindResponseBuilder
)

type Event = sharedaudit.Event

func NewEvent(ctx context.Context, eventType EventType) Event {
	return sharedaudit.NewEvent(ctx, eventType)
}

func NewSuspiciousInputEvent(ctx context.Context, input, suspicion, reason string) Event {
	return sharedaudit.NewSuspiciousInputEvent(ctx, input, suspicion, reason)
}

func NewInteractionEvent(ctx context.Context, step Step) Event {
	return sharedaudit.NewInteractionEvent(ctx, step)
}
