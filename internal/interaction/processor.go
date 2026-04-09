package interaction

import (
	"errors"
	"github.com/Dylar/ai-trust-game/internal/domain"
	interactionexecution "github.com/Dylar/ai-trust-game/internal/interaction/execution"
	interactionplanning "github.com/Dylar/ai-trust-game/internal/interaction/planning"
	interactionpolicy "github.com/Dylar/ai-trust-game/internal/interaction/policy"
	interactionresponse "github.com/Dylar/ai-trust-game/internal/interaction/response"
	interactionstate "github.com/Dylar/ai-trust-game/internal/interaction/state"
)

var ErrEmptyInteractionMessage = errors.New("interaction message is empty")

type Processor struct {
	policyResolver    interactionpolicy.PolicyResolver
	planner           interactionplanning.Planner
	executor          interactionexecution.Executor
	stateUpdater      interactionstate.StateUpdater
	responseDataGuard interactionresponse.DataGuard
	responseBuilder   interactionresponse.Builder
	responseValidator interactionresponse.Validator
}

func NewProcessor(
	policyResolver interactionpolicy.PolicyResolver,
	planner interactionplanning.Planner,
	executor interactionexecution.Executor,
	stateUpdater interactionstate.StateUpdater,
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

func (processor Processor) Process(interaction domain.Interaction) (interactionresponse.Result, error) {
	if err := validate(interaction); err != nil {
		return interactionresponse.Result{}, err
	}

	sess := interaction.Session
	policy, err := processor.policyResolver.PolicyFor(sess.Settings.Mode)
	if err != nil {
		return interactionresponse.Result{}, err
	}

	plan, err := processor.planner.Plan(interaction.Message)
	if err != nil {
		return interactionresponse.Result{}, err
	}

	decision := policy.Decide(interactionpolicy.DecisionInput{
		Session: sess,
		Claims:  plan.Claims,
		Action:  plan.Action,
	})
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

	responseInput := interactionresponse.Input{
		Session: interactionresponse.SessionMeta{
			ID:   interaction.Session.ID,
			Role: interaction.Session.Settings.Role,
			Mode: interaction.Session.Settings.Mode,
		},
		Request: interactionresponse.RequestMeta{
			UserMessage:       interaction.Message,
			Action:            plan.Action,
			SubmittedPassword: plan.SubmittedPassword,
			DecisionReason:    decision.Reason,
		},
		Payload: interactionresponse.Payload{
			AvailableActions: execution.AvailableActions,
			Secret:           execution.Secret,
			UserProfile:      execution.UserProfile,
			PasswordCheck: &interactionresponse.PasswordCheck{
				Submitted: plan.SubmittedPassword != "",
				Correct:   execution.PasswordCorrect,
			},
		},
	}
	response := processor.responseDataGuard.Guard(responseInput)
	result := processor.responseBuilder.Build(response)
	result = processor.responseValidator.Validate(interactionresponse.ValidatorInput{
		Response: response,
		Result:   result,
	})

	updatedSession, updated := processor.stateUpdater.Update(interactionstate.StateUpdateInput{
		Session:         sess,
		Plan:            plan,
		DecisionAllowed: decision.Allowed,
		PasswordCorrect: execution.PasswordCorrect,
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
