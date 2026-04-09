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

	if input.Action == domain.ActionReadUserProfile {
		if input.Claims.Role == domain.RoleAdmin || input.Claims.Role == domain.RoleEmployee {
			return Decision{Allowed: true, Reason: "medium mode trusts role claim for user profile"}
		}
		if input.Session.Role == domain.RoleAdmin || input.Session.Role == domain.RoleEmployee {
			return Decision{Allowed: true, Reason: "medium mode accepts verified employee access to user profile"}
		}
		return Decision{Allowed: false, Reason: "medium mode denied non-employee user profile access"}
	}

	return Decision{Allowed: true, Reason: "no safety-relevant action"}
}
