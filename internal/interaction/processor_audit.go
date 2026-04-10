package interaction

import (
	"context"

	"github.com/Dylar/ai-trust-game/internal/domain"
	interactionexecution "github.com/Dylar/ai-trust-game/internal/interaction/execution"
	interactionplanning "github.com/Dylar/ai-trust-game/internal/interaction/planning"
	interactionpolicy "github.com/Dylar/ai-trust-game/internal/interaction/policy"
	interactionresponse "github.com/Dylar/ai-trust-game/internal/interaction/response"
	"github.com/Dylar/ai-trust-game/pkg/audit"
)

func (processor Processor) writeAuditEvent(ctx context.Context, event audit.Event) {
	_ = processor.auditSink.WriteEvent(ctx, event)
}

func newInteractionAuditEvent(
	ctx context.Context,
	step audit.Step,
	interaction domain.Interaction,
) audit.Event {
	event := audit.NewInteractionEvent(ctx, step)
	event.Action = domain.ActionChat
	event.Mode = interaction.Session.Settings.Mode
	event.Role = interaction.Session.Settings.Role
	event.Input = interaction.Message
	return event
}

func plannedAuditEvent(
	ctx context.Context,
	interaction domain.Interaction,
	plan interactionplanning.Plan,
) audit.Event {
	event := newInteractionAuditEvent(ctx, audit.StepPlanned, interaction)
	event.Action = plan.Action
	event.ClaimsRole = plan.Claims.Role
	return event
}

func decidedAuditEvent(
	ctx context.Context,
	interaction domain.Interaction,
	plan interactionplanning.Plan,
	decision interactionpolicy.Decision,
) audit.Event {
	event := newInteractionAuditEvent(ctx, audit.StepDecided, interaction)
	event.Action = plan.Action
	event.ClaimsRole = plan.Claims.Role
	if decision.Allowed {
		event.Outcome = audit.OutcomeAllowed
	} else {
		event.Outcome = audit.OutcomeDenied
	}
	event.Reason = decision.Reason
	return event
}

func executedAuditEvent(
	ctx context.Context,
	interaction domain.Interaction,
	plan interactionplanning.Plan,
	execution interactionexecution.ExecutionOutput,
) audit.Event {
	event := newInteractionAuditEvent(ctx, audit.StepExecuted, interaction)
	event.Action = plan.Action
	event.ClaimsRole = plan.Claims.Role
	event.Outcome = audit.Outcome(execution.Action)
	return event
}

func respondedAuditEvent(
	ctx context.Context,
	interaction domain.Interaction,
	plan interactionplanning.Plan,
	result interactionresponse.Result,
) audit.Event {
	event := newInteractionAuditEvent(ctx, audit.StepResponded, interaction)
	event.Action = plan.Action
	event.Source = audit.Source(result.Source)
	event.Outcome = audit.OutcomeResponseBuilt
	return event
}

func stateUpdatedAuditEvent(
	ctx context.Context,
	interaction domain.Interaction,
	plan interactionplanning.Plan,
	updated bool,
) audit.Event {
	event := newInteractionAuditEvent(ctx, audit.StepStateUpdated, interaction)
	event.Action = plan.Action
	if updated {
		event.Outcome = audit.OutcomeUpdated
	} else {
		event.Outcome = audit.OutcomeUnchanged
	}
	return event
}
