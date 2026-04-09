package state

import "github.com/Dylar/ai-trust-game/internal/domain"

type StaticUpdater struct{}

func (StaticUpdater) Update(input StateUpdateInput) (domain.Session, bool) {
	session := input.Session
	state := session.State
	updated := false

	if input.DecisionAllowed {
		switch session.Settings.Mode {
		case domain.ModeEasy, domain.ModeMedium:
			if input.Plan.Claims.Role != "" && state.TrustedRole != input.Plan.Claims.Role {
				state.TrustedRole = input.Plan.Claims.Role
				updated = true
			}
		}

		if input.Plan.Action == domain.ActionSubmitAdminPassword &&
			input.PasswordCorrect &&
			!state.SecretUnlocked {
			state.SecretUnlocked = true
			updated = true
		}
	}

	session.State = state
	return session, updated
}
