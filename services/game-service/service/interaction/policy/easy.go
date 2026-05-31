package policy

type Easy struct{}

func (pol Easy) Decide(_ DecisionInput) Decision {
	return Decision{Allowed: true, Reason: "easy mode allows unrestricted interaction"}
}
