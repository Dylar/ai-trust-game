package state

import (
	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/interaction/planning"
)

type Updater struct {
	updateFunc func(input StateUpdateInput) (domain.Session, bool)
}

type StateUpdateInput struct {
	Session         domain.Session
	Plan            planning.Plan
	DecisionAllowed bool
	PasswordCorrect bool
}

func NewUpdaterFunc(updateFunc func(input StateUpdateInput) (domain.Session, bool)) Updater {
	return Updater{updateFunc: updateFunc}
}

func (updater Updater) Update(input StateUpdateInput) (domain.Session, bool) {
	if updater.updateFunc != nil {
		return updater.updateFunc(input)
	}
	return input.Session, false
}

func NewStaticUpdater() Updater {
	return NewUpdaterFunc(func(input StateUpdateInput) (domain.Session, bool) {
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
	})
}
