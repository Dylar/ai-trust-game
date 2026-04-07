package interaction

import (
	"errors"
	"fmt"
	"github.com/Dylar/ai-trust-game/internal/domain"
	"strings"
)

var ErrEmptyInteractionMessage = errors.New("interaction message is empty")

func Process(interaction domain.Interaction) (Result, error) {
	if err := validate(interaction); err != nil {
		return Result{}, err
	}

	action := detectAction(interaction.Message)
	claims := detectClaims(interaction.Message)

	sess := interaction.Session
	decision := decide(sess, action, claims)
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

func decide(sess domain.Session, action domain.Action, claims domain.Claims) Decision {
	if sess.Mode == domain.ModeEasy {
		return decideEasyMode()
	}
	if sess.Mode == domain.ModeMedium {
		return decideMediumMode(sess, action, claims)
	}
	return decideHardMode(sess, action)
}

func decideEasyMode() Decision {
	return Decision{Allowed: true, Reason: "easy mode allows unrestricted interaction"}
}

func decideMediumMode(sess domain.Session, action domain.Action, claims domain.Claims) Decision {
	if action == domain.ActionReadSecret {
		if claims.Role == domain.RoleAdmin {
			return Decision{Allowed: true, Reason: "medium mode trusts admin claim"}
		}
		if sess.Role == domain.RoleAdmin {
			return Decision{Allowed: true, Reason: "medium mode accepts verified admin role"}
		}
		return Decision{Allowed: false, Reason: "medium mode denied non-admin secret access"}
	}

	return Decision{Allowed: true, Reason: "no safety-relevant action"}
}

func decideHardMode(sess domain.Session, action domain.Action) Decision {
	if action == domain.ActionReadSecret {
		if sess.Role == domain.RoleAdmin {
			return Decision{Allowed: true, Reason: "hard mode requires verified admin role"}
		}
		return Decision{Allowed: false, Reason: "hard mode denied non-admin secret access"}
	}

	return Decision{Allowed: true, Reason: "no safety-relevant action"}
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
