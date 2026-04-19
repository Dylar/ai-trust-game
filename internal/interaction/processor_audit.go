package interaction

import (
	"context"
	"errors"

	"github.com/Dylar/ai-trust-game/internal/domain"
	interactionexecution "github.com/Dylar/ai-trust-game/internal/interaction/execution"
	interactionplanning "github.com/Dylar/ai-trust-game/internal/interaction/planning"
	interactionpolicy "github.com/Dylar/ai-trust-game/internal/interaction/policy"
	interactionresponse "github.com/Dylar/ai-trust-game/internal/interaction/response"
	"github.com/Dylar/ai-trust-game/internal/llm"
	"github.com/Dylar/ai-trust-game/pkg/audit"
	"github.com/Dylar/ai-trust-game/pkg/logging"
)

func (processor Processor) writeAuditEvent(ctx context.Context, event audit.Event) {
	if err := processor.auditSink.WriteEvent(ctx, event); err != nil {
		processor.logger.Warn(
			ctx,
			"failed to write audit event",
			logging.WithError(err),
			logging.WithField("audit_step", event.Step),
			logging.WithField("audit_action", event.Action),
		)
	}
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
	plan domain.Plan,
) audit.Event {
	event := newInteractionAuditEvent(ctx, audit.StepPlanned, interaction)
	event.Action = plan.Action
	event.ClaimsRole = plan.Claims.Role
	event.Stage = string(llm.StagePlanner)
	return event
}

func planningFailedAuditEvent(
	ctx context.Context,
	interaction domain.Interaction,
	err error,
) audit.Event {
	event := newInteractionAuditEvent(ctx, audit.StepPlanned, interaction)
	event.Stage = string(llm.StagePlanner)
	event.Outcome = audit.OutcomeFailed
	event.Reason = err.Error()
	event.Failure = audit.FailureKindPlannerClient

	var outputErr interactionplanning.OutputError
	if errors.As(err, &outputErr) {
		event.Failure = audit.FailureKindPlannerOutput
		event.HasOutput = outputErr.RawOutput != ""
	}

	return event
}

func decidedAuditEvent(
	ctx context.Context,
	interaction domain.Interaction,
	plan domain.Plan,
	decision interactionpolicy.Decision,
) audit.Event {
	event := newInteractionAuditEvent(ctx, audit.StepDecided, interaction)
	event.Action = plan.Action
	event.ClaimsRole = plan.Claims.Role
	event.Outcome = audit.OutcomeDenied
	if decision.Allowed {
		event.Outcome = audit.OutcomeAllowed
	}
	event.Reason = decision.Reason
	return event
}

func executedAuditEvent(
	ctx context.Context,
	interaction domain.Interaction,
	plan domain.Plan,
	execution interactionexecution.Output,
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
	plan domain.Plan,
	result interactionresponse.Result,
) audit.Event {
	event := newInteractionAuditEvent(ctx, audit.StepResponded, interaction)
	event.Action = plan.Action
	event.Source = audit.Source(result.Source)
	event.Outcome = audit.OutcomeResponseBuilt
	event.Stage = string(llm.StageResponseBuilder)
	return event
}

func responseBuildFailedAuditEvent(
	ctx context.Context,
	interaction domain.Interaction,
	plan domain.Plan,
	err error,
) audit.Event {
	event := newInteractionAuditEvent(ctx, audit.StepResponded, interaction)
	event.Action = plan.Action
	event.ClaimsRole = plan.Claims.Role
	event.Stage = string(llm.StageResponseBuilder)
	event.Outcome = audit.OutcomeFailed
	event.Reason = err.Error()
	event.Failure = audit.FailureKindResponseBuilder
	return event
}

func stateUpdatedAuditEvent(
	ctx context.Context,
	interaction domain.Interaction,
	plan domain.Plan,
	updated bool,
) audit.Event {
	event := newInteractionAuditEvent(ctx, audit.StepStateUpdated, interaction)
	event.Action = plan.Action
	event.Outcome = audit.OutcomeUnchanged
	if updated {
		event.Outcome = audit.OutcomeUpdated
	}
	return event
}
