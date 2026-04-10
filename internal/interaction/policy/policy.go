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

type Resolver struct {
	resolveFunc func(mode domain.Mode) (Policy, error)
}

func NewResolverFunc(resolveFunc func(mode domain.Mode) (Policy, error)) Resolver {
	return Resolver{resolveFunc: resolveFunc}
}

func NewDefaultResolver() Resolver {
	return NewResolverFunc(func(mode domain.Mode) (Policy, error) {
		switch mode {
		case domain.ModeEasy:
			return PolicyEasy{}, nil
		case domain.ModeMedium:
			return PolicyMedium{}, nil
		case domain.ModeHard:
			return PolicyHard{}, nil
		}
		return nil, fmt.Errorf("unknown policy mode %v", mode)
	})
}

func (resolver Resolver) PolicyFor(mode domain.Mode) (Policy, error) {
	if resolver.resolveFunc != nil {
		return resolver.resolveFunc(mode)
	}
	return nil, fmt.Errorf("unknown policy mode %v", mode)
}
