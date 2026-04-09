package interaction

import "github.com/Dylar/ai-trust-game/internal/domain"

type StaticStateUpdater struct{}

func (StaticStateUpdater) Update(input StateUpdateInput) (domain.Session, bool) {
	session := input.Session
	state := session.State
	updated := false

	if input.Decision.Allowed {
		switch session.Settings.Mode {
		case domain.ModeEasy, domain.ModeMedium:
			if input.Plan.Claims.Role != "" && state.TrustedRole != input.Plan.Claims.Role {
				state.TrustedRole = input.Plan.Claims.Role
				updated = true
			}
		}

		if input.Plan.Action == domain.ActionSubmitAdminPassword &&
			input.Execution.PasswordCorrect &&
			!state.SecretUnlocked {
			state.SecretUnlocked = true
			updated = true
		}
	}

	session.State = state
	return session, updated
}
