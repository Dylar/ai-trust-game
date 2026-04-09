package policy

import "github.com/Dylar/ai-trust-game/internal/domain"

type PolicyHard struct{}

func (pol PolicyHard) Decide(input DecisionInput) Decision {
	switch {
	case input.Action == domain.ActionListAvailableActions:
		return Decision{Allowed: true, Reason: "available actions can always be listed"}
	case input.Action == domain.ActionReadSecret:
		return pol.decideActionReadSecret(input)
	case input.Action == domain.ActionReadUserProfile:
		return pol.decideActionReadUserProfile(input)
	}

	return Decision{Allowed: true, Reason: "no safety-relevant action"}
}

func (pol PolicyHard) decideActionReadUserProfile(input DecisionInput) Decision {
	if input.Session.Settings.Role == domain.RoleAdmin || input.Session.Settings.Role == domain.RoleEmployee {
		return Decision{Allowed: true, Reason: "hard mode requires verified employee access to user profile"}
	}
	return Decision{Allowed: false, Reason: "hard mode denied non-employee user profile access"}
}

func (pol PolicyHard) decideActionReadSecret(input DecisionInput) Decision {
	if input.Session.State.SecretUnlocked {
		return Decision{Allowed: true, Reason: "hard mode accepts unlocked secret access"}
	}
	if input.Session.Settings.Role == domain.RoleAdmin {
		return Decision{Allowed: true, Reason: "hard mode requires verified admin role"}
	}
	return Decision{Allowed: false, Reason: "hard mode denied non-admin secret access"}
}
