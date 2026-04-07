package interaction

import (
	"errors"
	"fmt"
	"github.com/Dylar/ai-trust-game/internal/domain"
)

var ErrEmptyInteractionMessage = errors.New("interaction message is empty")

type Source string

const (
	SourceSystem Source = "system"
	SourceLLM    Source = "llm"
)

type Result struct {
	Message string

	Source Source
}

func Process(i domain.Interaction) (Result, error) {
	if err := validate(i); err != nil {
		return Result{}, err
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
