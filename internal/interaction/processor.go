package interaction

import (
	"errors"
	"github.com/Dylar/ai-trust-game/internal/domain"
	interactionresponse "github.com/Dylar/ai-trust-game/internal/interaction/response"
)

var ErrEmptyInteractionMessage = errors.New("interaction message is empty")

type Processor struct {
	policyResolver    PolicyResolver
	planner           Planner
	executor          Executor
	stateUpdater      StateUpdater
	responseDataGuard interactionresponse.DataGuard
	responseBuilder   interactionresponse.Builder
	responseValidator interactionresponse.Validator
}

func NewProcessor(
	policyResolver PolicyResolver,
	planner Planner,
	executor Executor,
	stateUpdater StateUpdater,
	responseDataGuard interactionresponse.DataGuard,
	responseBuilder interactionresponse.Builder,
	responseValidator interactionresponse.Validator,
) Processor {
	return Processor{
		policyResolver:    policyResolver,
		planner:           planner,
		executor:          executor,
		stateUpdater:      stateUpdater,
		responseDataGuard: responseDataGuard,
		responseBuilder:   responseBuilder,
		responseValidator: responseValidator,
	}
}

func (processor Processor) Process(interaction domain.Interaction) (Result, error) {
	if err := validate(interaction); err != nil {
		return Result{}, err
	}

	sess := interaction.Session
	policy, err := processor.policyResolver.PolicyFor(sess.Settings.Mode)
	if err != nil {
		return Result{}, err
	}

	plan, err := processor.planner.Plan(interaction.Message)
	if err != nil {
		return Result{}, err
	}

	decision := policy.Decide(DecisionInput{
		Session: sess,
		Claims:  plan.Claims,
		Action:  plan.Action,
	})
	if !decision.Allowed {
		return Result{
			Message: "interaction denied",
			Source:  SourceSystem,
		}, nil
	}

	execution, err := processor.executor.Execute(ExecutionInput{
		Session: sess,
		Plan:    plan,
	})
	if err != nil {
		return Result{}, err
	}

	responseInput := interactionresponse.Input{
		Session:           interaction.Session,
		UserMessage:       interaction.Message,
		Action:            plan.Action,
		SubmittedPassword: plan.SubmittedPassword,
		DecisionReason:    decision.Reason,
		AvailableActions:  execution.AvailableActions,
		Secret:            execution.Secret,
		UserProfile:       execution.UserProfile,
		PasswordCorrect:   execution.PasswordCorrect,
	}
	response := processor.responseDataGuard.Guard(responseInput)
	result := processor.responseBuilder.Build(response)
	result = processor.responseValidator.Validate(interactionresponse.ValidatorInput{
		Response: response,
		Result:   result,
	})

	updatedSession, updated := processor.stateUpdater.Update(StateUpdateInput{
		Session:   sess,
		Plan:      plan,
		Decision:  decision,
		Execution: execution,
	})
	if updated {
		result.UpdatedSession = &updatedSession
	}

	return result, nil
}

func validate(interaction domain.Interaction) error {
	if interaction.Message == "" {
		return ErrEmptyInteractionMessage
	}
	return nil
}
