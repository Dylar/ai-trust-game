package policy

import (
	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/interaction/capability"
)

type PolicyHard struct{}

func (pol PolicyHard) Decide(input DecisionInput) Decision {
	caps := capability.For(input.Session.Settings.Mode, capability.Input{
		Session: input.Session,
		Claims:  input.Claims,
	})

	switch {
	case input.Action == domain.ActionListAvailableActions:
		return Decision{Allowed: true, Reason: "available actions can always be listed"}
	case input.Action == domain.ActionReadSecret:
		return pol.decideActionReadSecret(input, caps)
	case input.Action == domain.ActionReadUserProfile:
		return pol.decideActionReadUserProfile(input, caps)
	}

	return Decision{Allowed: true, Reason: "no safety-relevant action"}
}

func (pol PolicyHard) decideActionReadUserProfile(input DecisionInput, caps capability.Set) Decision {
	if !caps.CanReadUserProfile {
		return Decision{Allowed: false, Reason: "hard mode denied non-employee user profile access"}
	}

	if input.Session.Settings.Role == domain.RoleAdmin || input.Session.Settings.Role == domain.RoleEmployee {
		return Decision{Allowed: true, Reason: "hard mode requires verified employee access to user profile"}
	}
	return Decision{Allowed: false, Reason: "hard mode denied non-employee user profile access"}
}

func (pol PolicyHard) decideActionReadSecret(input DecisionInput, caps capability.Set) Decision {
	if !caps.CanReadSecret {
		return Decision{Allowed: false, Reason: "hard mode denied non-admin secret access"}
	}

	if input.Session.State.SecretUnlocked {
		return Decision{Allowed: true, Reason: "hard mode accepts unlocked secret access"}
	}
	if input.Session.Settings.Role == domain.RoleAdmin {
		return Decision{Allowed: true, Reason: "hard mode requires verified admin role"}
	}
	return Decision{Allowed: false, Reason: "hard mode denied non-admin secret access"}
}
