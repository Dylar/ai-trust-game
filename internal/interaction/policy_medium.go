package interaction

import "github.com/Dylar/ai-trust-game/internal/domain"

type PolicyMedium struct{}

func (pol PolicyMedium) Decide(input DecisionInput) Decision {
	switch {
	case input.Action == domain.ActionReadUserProfile:
		return pol.decideActionReadUserProfile(input)
	case input.Action == domain.ActionReadSecret:
		return pol.decideActionReadSecret(input)
	}
	return Decision{Allowed: true, Reason: "no safety-relevant action"}
}

func (pol PolicyMedium) decideActionReadUserProfile(input DecisionInput) Decision {
	if input.Claims.Role == domain.RoleAdmin || input.Claims.Role == domain.RoleEmployee {
		return Decision{Allowed: true, Reason: "medium mode trusts role claim for user profile"}
	}
	if input.Session.State.TrustedRole == domain.RoleAdmin || input.Session.State.TrustedRole == domain.RoleEmployee {
		return Decision{Allowed: true, Reason: "medium mode accepts trusted role access to user profile"}
	}
	if input.Session.Settings.Role == domain.RoleAdmin || input.Session.Settings.Role == domain.RoleEmployee {
		return Decision{Allowed: true, Reason: "medium mode accepts verified employee access to user profile"}
	}
	return Decision{Allowed: false, Reason: "medium mode denied non-employee user profile access"}
}

func (pol PolicyMedium) decideActionReadSecret(input DecisionInput) Decision {
	if input.Claims.Role == domain.RoleAdmin {
		return Decision{Allowed: true, Reason: "medium mode trusts admin claim"}
	}
	if input.Session.Settings.Role == domain.RoleAdmin {
		return Decision{Allowed: true, Reason: "medium mode accepts verified admin role"}
	}
	return Decision{Allowed: false, Reason: "medium mode denied non-admin secret access"}
}
