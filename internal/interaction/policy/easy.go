package policy

type PolicyEasy struct{}

func (pol PolicyEasy) Decide(_ DecisionInput) Decision {
	return Decision{Allowed: true, Reason: "easy mode allows unrestricted interaction"}
}
