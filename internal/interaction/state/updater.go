package state

import (
	"github.com/Dylar/ai-trust-game/internal/domain"
)

type Updater struct{}

type Input struct {
	Session         domain.Session
	Plan            domain.Plan
	DecisionAllowed bool
	PasswordCorrect bool
}

func NewUpdater() Updater {
	return Updater{}
}

func (Updater) Update(input Input) (domain.Session, bool) {
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
