package interaction

import "github.com/Dylar/ai-trust-game/internal/domain"

type PolicyHard struct{}

func (pol PolicyHard) Decide(input DecisionInput) Decision {
	if input.Action == domain.ActionReadSecret {
		if input.Session.Role == domain.RoleAdmin {
			return Decision{Allowed: true, Reason: "hard mode requires verified admin role"}
		}
		return Decision{Allowed: false, Reason: "hard mode denied non-admin secret access"}
	}

	return Decision{Allowed: true, Reason: "no safety-relevant action"}
}
