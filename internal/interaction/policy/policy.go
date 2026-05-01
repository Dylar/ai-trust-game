package policy

import (
	"fmt"

	"github.com/Dylar/ai-trust-game/internal/domain"
)

type Policy interface {
	Decide(input DecisionInput) Decision
}

type DecisionInput struct {
	Session domain.Session
	Action  domain.Action
	Claims  domain.Claims
}

type Decision struct {
	Allowed bool
	Reason  string
}

type Resolver struct{}

func NewResolver() Resolver {
	return Resolver{}
}

func (Resolver) PolicyFor(mode domain.Mode) (Policy, error) {
	switch mode {
	case domain.ModeEasy:
		return Easy{}, nil
	case domain.ModeMedium:
		return Medium{}, nil
	case domain.ModeHard:
		return Hard{}, nil
	}
	return nil, fmt.Errorf("unknown policy mode %v", mode)
}
