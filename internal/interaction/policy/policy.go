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

type PolicyResolver struct{}

func NewDefaultPolicyResolver() PolicyResolver {
	return PolicyResolver{}
}

func (PolicyResolver) PolicyFor(mode domain.Mode) (Policy, error) {
	switch mode {
	case domain.ModeEasy:
		return PolicyEasy{}, nil
	case domain.ModeMedium:
		return PolicyMedium{}, nil
	case domain.ModeHard:
		return PolicyHard{}, nil
	}
	return nil, fmt.Errorf("unknown policy mode %v", mode)
}
