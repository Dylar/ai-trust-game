package interaction

import (
	"errors"
	"github.com/Dylar/ai-trust-game/internal/domain"
)

var ErrEmptyInteractionMessage = errors.New("interaction message is empty")

type Processor struct {
	policyResolver  PolicyResolver
	planner         Planner
	executor        Executor
	responseBuilder ResponseBuilder
}

func NewProcessor(policyResolver PolicyResolver, planner Planner, executor Executor, responseBuilder ResponseBuilder) Processor {
	return Processor{
		policyResolver:  policyResolver,
		planner:         planner,
		executor:        executor,
		responseBuilder: responseBuilder,
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

	return processor.responseBuilder.Build(ResponseInput{
		Interaction: interaction,
		Plan:        plan,
		Decision:    decision,
		Execution:   execution,
	}), nil
}

func validate(interaction domain.Interaction) error {
	if interaction.Message == "" {
		return ErrEmptyInteractionMessage
	}
	return nil
}
