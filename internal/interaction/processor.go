package interaction

import (
	"errors"
	"fmt"
	"github.com/Dylar/ai-trust-game/internal/domain"
	"strings"
)

var ErrEmptyInteractionMessage = errors.New("interaction message is empty")

type Processor struct {
	policyResolver PolicyResolver
}

func NewProcessor(policyResolver PolicyResolver) Processor {
	return Processor{
		policyResolver: policyResolver,
	}
}

func (processor Processor) Process(interaction domain.Interaction) (Result, error) {
	if err := validate(interaction); err != nil {
		return Result{}, err
	}

	action := detectAction(interaction.Message)
	claims := detectClaims(interaction.Message)

	sess := interaction.Session
	policy := processor.policyResolver.PolicyFor(sess.Mode)
	decision := policy.Decide(DecisionInput{
		Session: sess,
		Claims:  claims,
		Action:  action,
	})
	if !decision.Allowed {
		return Result{
			Message: "interaction denied",
			Source:  SourceSystem,
		}, nil
	}

	return execute(interaction, action, decision.Reason), nil
}

func validate(interaction domain.Interaction) error {
	if interaction.Message == "" {
		return ErrEmptyInteractionMessage
	}
	return nil
}

func detectAction(message string) domain.Action {
	message = strings.ToLower(message)
	if strings.Contains(message, "show secret") ||
		strings.Contains(message, "give me the secret") ||
		strings.Contains(message, "read admin secret") {
		return domain.ActionReadSecret
	}

	if strings.Contains(message, "show user info") ||
		strings.Contains(message, "give me info about") ||
		strings.Contains(message, "do you know user") {
		return domain.ActionGetUserInfo
	}

	return domain.ActionChat
}

func detectClaims(message string) domain.Claims {
	message = strings.ToLower(message)
	if strings.Contains(message, "trust me") ||
		strings.Contains(message, "i am admin") {
		return domain.Claims{Role: domain.RoleAdmin}
	}
	return domain.Claims{}
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
