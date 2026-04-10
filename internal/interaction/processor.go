package interaction

import (
	"context"
	"errors"

	"github.com/Dylar/ai-trust-game/internal/domain"
	interactionexecution "github.com/Dylar/ai-trust-game/internal/interaction/execution"
	interactionplanning "github.com/Dylar/ai-trust-game/internal/interaction/planning"
	interactionpolicy "github.com/Dylar/ai-trust-game/internal/interaction/policy"
	interactionresponse "github.com/Dylar/ai-trust-game/internal/interaction/response"
	interactionstate "github.com/Dylar/ai-trust-game/internal/interaction/state"
	"github.com/Dylar/ai-trust-game/pkg/audit"
)

var ErrEmptyInteractionMessage = errors.New("interaction message is empty")

type plannerPort interface {
	Plan(message string) (interactionplanning.Plan, error)
}

type policyResolverPort interface {
	PolicyFor(mode domain.Mode) (interactionpolicy.Policy, error)
}

type executorPort interface {
	Execute(input interactionexecution.ExecutionInput) (interactionexecution.ExecutionOutput, error)
}

type stateUpdaterPort interface {
	Update(input interactionstate.StateUpdateInput) (domain.Session, bool)
}

type responseDataGuardPort interface {
	Guard(input interactionresponse.Input) interactionresponse.Input
}

type responseBuilderPort interface {
	Build(ctx context.Context, input interactionresponse.Input) interactionresponse.Result
}

type responseValidatorPort interface {
	Validate(input interactionresponse.ValidatorInput) interactionresponse.Result
}

type Processor struct {
	policyResolver    policyResolverPort
	planner           plannerPort
	executor          executorPort
	stateUpdater      stateUpdaterPort
	responseDataGuard responseDataGuardPort
	responseBuilder   responseBuilderPort
	responseValidator responseValidatorPort
	auditSink         audit.Sink
}

func NewProcessor(
	policyResolver policyResolverPort,
	planner plannerPort,
	executor executorPort,
	stateUpdater stateUpdaterPort,
	responseDataGuard responseDataGuardPort,
	responseBuilder responseBuilderPort,
	responseValidator responseValidatorPort,
	auditSink audit.Sink,
) Processor {
	if auditSink == nil {
		auditSink = audit.NewNoopSink()
	}

	return Processor{
		policyResolver:    policyResolver,
		planner:           planner,
		executor:          executor,
		stateUpdater:      stateUpdater,
		responseDataGuard: responseDataGuard,
		responseBuilder:   responseBuilder,
		responseValidator: responseValidator,
		auditSink:         auditSink,
	}
}

func (processor Processor) Process(ctx context.Context, interaction domain.Interaction) (interactionresponse.Result, error) {
	if err := validate(interaction); err != nil {
		return interactionresponse.Result{}, err
	}

	plan, err := processor.planner.Plan(interaction.Message)
	if err != nil {
		return interactionresponse.Result{}, err
	}
	processor.writeAuditEvent(ctx, plannedAuditEvent(ctx, interaction, plan))

	sess := interaction.Session
	policy, err := processor.policyResolver.PolicyFor(sess.Settings.Mode)
	if err != nil {
		return interactionresponse.Result{}, err
	}

	decision := policy.Decide(interactionpolicy.DecisionInput{
		Session: sess,
		Claims:  plan.Claims,
		Action:  plan.Action,
	})
	processor.writeAuditEvent(ctx, decidedAuditEvent(ctx, interaction, plan, decision))
	if !decision.Allowed {
		return interactionresponse.Result{
			Message: "interaction denied",
			Source:  interactionresponse.SourceSystem,
		}, nil
	}

	execution, err := processor.executor.Execute(interactionexecution.ExecutionInput{
		Session: sess,
		Plan:    plan,
	})
	if err != nil {
		return interactionresponse.Result{}, err
	}
	processor.writeAuditEvent(ctx, executedAuditEvent(ctx, interaction, plan, execution))

	responseInput := newResponseInput(interaction, plan, decision, execution)
	response := processor.responseDataGuard.Guard(responseInput)
	result := processor.responseBuilder.Build(ctx, response)
	result = processor.responseValidator.Validate(interactionresponse.ValidatorInput{
		Response: response,
		Result:   result,
	})
	processor.writeAuditEvent(ctx, respondedAuditEvent(ctx, interaction, plan, result))

	updatedSession, updated := processor.stateUpdater.Update(interactionstate.StateUpdateInput{
		Session:         sess,
		Plan:            plan,
		DecisionAllowed: decision.Allowed,
		PasswordCorrect: execution.PasswordCorrect,
	})
	if updated {
		result.UpdatedSession = &updatedSession
	}
	processor.writeAuditEvent(ctx, stateUpdatedAuditEvent(ctx, interaction, plan, updated))

	return result, nil
}

func validate(interaction domain.Interaction) error {
	if interaction.Message == "" {
		return ErrEmptyInteractionMessage
	}
	return nil
}
