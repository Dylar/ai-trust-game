package policy

import (
	"fmt"
	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/interaction/capability"
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

type PolicyResolver interface {
	PolicyFor(mode domain.Mode) (Policy, error)
}

type DefaultPolicyResolver struct{}

func (DefaultPolicyResolver) PolicyFor(mode domain.Mode) (Policy, error) {
	switch mode {
	case domain.ModeEasy:
		return PolicyEasy{}, nil
	case domain.ModeMedium:
		return PolicyMedium{capabilityResolver: capability.StaticResolver{}}, nil
	case domain.ModeHard:
		return PolicyHard{capabilityResolver: capability.StaticResolver{}}, nil
	}
	return nil, fmt.Errorf("unknown policy mode %v", mode)
}
