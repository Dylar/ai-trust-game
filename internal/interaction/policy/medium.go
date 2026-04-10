package policy

import (
	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/interaction/capability"
)

type Medium struct{}

func (pol Medium) Decide(input DecisionInput) Decision {
	caps := capability.For(input.Session.Settings.Mode, capability.Input{
		Session: input.Session,
		Claims:  input.Claims,
	})

	switch {
	case input.Action == domain.ActionListAvailableActions:
		return Decision{Allowed: true, Reason: "available actions can always be listed"}
	case input.Action == domain.ActionReadUserProfile:
		return pol.decideActionReadUserProfile(input, caps)
	case input.Action == domain.ActionReadSecret:
		return pol.decideActionReadSecret(input, caps)
	}
	return Decision{Allowed: true, Reason: "no safety-relevant action"}
}

func (pol Medium) decideActionReadUserProfile(input DecisionInput, caps capability.Set) Decision {
	if !caps.CanReadUserProfile {
		return Decision{Allowed: false, Reason: "medium mode denied non-employee user profile access"}
	}

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

func (pol Medium) decideActionReadSecret(input DecisionInput, caps capability.Set) Decision {
	if !caps.CanReadSecret {
		return Decision{Allowed: false, Reason: "medium mode denied non-admin secret access"}
	}

	if input.Claims.Role == domain.RoleAdmin {
		return Decision{Allowed: true, Reason: "medium mode trusts admin claim"}
	}
	if input.Session.State.SecretUnlocked {
		return Decision{Allowed: true, Reason: "medium mode accepts unlocked secret access"}
	}
	if input.Session.State.TrustedRole == domain.RoleAdmin {
		return Decision{Allowed: true, Reason: "medium mode accepts trusted admin access"}
	}
	if input.Session.Settings.Role == domain.RoleAdmin {
		return Decision{Allowed: true, Reason: "medium mode accepts verified admin role"}
	}
	return Decision{Allowed: false, Reason: "medium mode denied non-admin secret access"}
}
