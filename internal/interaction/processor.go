package interaction

import (
	"errors"
	"fmt"
	"github.com/Dylar/ai-trust-game/internal/domain"
	"strings"
)

var ErrEmptyInteractionMessage = errors.New("interaction message is empty")

func Process(i domain.Interaction) (Result, error) {
	if err := validate(i); err != nil {
		return Result{}, err
	}

	decision := decide(i)
	if !decision.Allowed {
		return Result{
			Message: "interaction denied",
			Source:  SourceSystem,
		}, nil
	}

	return execute(i), nil
}

func validate(i domain.Interaction) error {
	if i.Message == "" {
		return ErrEmptyInteractionMessage
	}
	return nil
}

func execute(i domain.Interaction) Result {
	return Result{
		Message: fmt.Sprintf(
			"Interacting with session %s, Role: %s, Mode: %s",
			i.Session.ID,
			i.Session.Role,
			i.Session.Mode,
		),
		Source: SourceSystem,
	}
}
