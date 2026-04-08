package interaction

import "github.com/Dylar/ai-trust-game/internal/domain"

type PolicyMedium struct{}

func (pol PolicyMedium) Decide(input DecisionInput) Decision {
	if input.Action == domain.ActionReadSecret {
		if input.Claims.Role == domain.RoleAdmin {
			return Decision{Allowed: true, Reason: "medium mode trusts admin claim"}
		}
		if input.Session.Role == domain.RoleAdmin {
			return Decision{Allowed: true, Reason: "medium mode accepts verified admin role"}
		}
		return Decision{Allowed: false, Reason: "medium mode denied non-admin secret access"}
	}

	return Decision{Allowed: true, Reason: "no safety-relevant action"}
}
