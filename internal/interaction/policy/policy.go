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

type PolicyResolver struct {
	resolveFunc func(mode domain.Mode) (Policy, error)
}

func NewPolicyResolverFunc(resolveFunc func(mode domain.Mode) (Policy, error)) PolicyResolver {
	return PolicyResolver{resolveFunc: resolveFunc}
}

func NewDefaultPolicyResolver() PolicyResolver {
	return NewPolicyResolverFunc(func(mode domain.Mode) (Policy, error) {
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

func (resolver PolicyResolver) PolicyFor(mode domain.Mode) (Policy, error) {
	if resolver.resolveFunc != nil {
		return resolver.resolveFunc(mode)
	}
	return nil, fmt.Errorf("unknown policy mode %v", mode)
}
