package interaction

import (
	"github.com/Dylar/ai-trust-game/internal/domain"
	interactionpolicy "github.com/Dylar/ai-trust-game/internal/interaction/policy"
)

type stubPolicy struct {
	decision interactionpolicy.Decision
}

func (policy stubPolicy) Decide(_ interactionpolicy.DecisionInput) interactionpolicy.Decision {
	return policy.decision
}

type spyPolicy struct {
	decision  interactionpolicy.Decision
	lastInput interactionpolicy.DecisionInput
}

func (policy *spyPolicy) Decide(input interactionpolicy.DecisionInput) interactionpolicy.Decision {
	policy.lastInput = input
	return policy.decision
}

type stubPolicyResolver struct {
	policy interactionpolicy.Policy
}

func (resolver stubPolicyResolver) build() interactionpolicy.Resolver {
	return interactionpolicy.NewResolverFunc(func(_ domain.Mode) (interactionpolicy.Policy, error) {
		return resolver.policy, nil
	})
}

type spyPolicyResolver struct {
	policy   interactionpolicy.Policy
	lastMode domain.Mode
}

func (resolver *spyPolicyResolver) build() interactionpolicy.Resolver {
	return interactionpolicy.NewResolverFunc(func(mode domain.Mode) (interactionpolicy.Policy, error) {
		resolver.lastMode = mode
		return resolver.policy, nil
	})
}
