package interaction

import "github.com/Dylar/ai-trust-game/internal/domain"

type stubPolicy struct {
	decision Decision
}

func (policy stubPolicy) Decide(_ DecisionInput) Decision {
	return policy.decision
}

type spyPolicy struct {
	decision  Decision
	lastInput DecisionInput
}

func (policy *spyPolicy) Decide(input DecisionInput) Decision {
	policy.lastInput = input
	return policy.decision
}

type stubPolicyResolver struct {
	policy Policy
}

func (resolver stubPolicyResolver) PolicyFor(_ domain.Mode) (Policy, error) {
	return resolver.policy, nil
}

type spyPolicyResolver struct {
	policy   Policy
	lastMode domain.Mode
}

func (resolver *spyPolicyResolver) PolicyFor(mode domain.Mode) (Policy, error) {
	resolver.lastMode = mode
	return resolver.policy, nil
}
