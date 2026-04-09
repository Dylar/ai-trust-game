package interaction

import (
	"errors"
	"fmt"
	"github.com/Dylar/ai-trust-game/internal/domain"
)

var ErrEmptyInteractionMessage = errors.New("interaction message is empty")

type Processor struct {
	policyResolver PolicyResolver
	planner        Planner
}

func NewProcessor(policyResolver PolicyResolver, planner Planner) Processor {
	return Processor{
		policyResolver: policyResolver,
		planner:        planner,
	}
}

func (processor Processor) Process(interaction domain.Interaction) (Result, error) {
	if err := validate(interaction); err != nil {
		return Result{}, err
	}

	sess := interaction.Session
	policy, err := processor.policyResolver.PolicyFor(sess.Mode)
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

	return execute(interaction, plan.Action, decision.Reason), nil
}

func validate(interaction domain.Interaction) error {
	if interaction.Message == "" {
		return ErrEmptyInteractionMessage
	}
	return nil
}

func execute(i domain.Interaction, action domain.Action, reason string) Result {
	return Result{
		Message: fmt.Sprintf(
			"Interacting with session %s, Role: %s, Mode: %s, Action: %s, Reason: %s",
			i.Session.ID,
			i.Session.Role,
			i.Session.Mode,
			action,
			reason,
		),
		Source: SourceSystem,
	}
}
