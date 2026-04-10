package interaction

import (
	"github.com/Dylar/ai-trust-game/internal/domain"
	interactionstate "github.com/Dylar/ai-trust-game/internal/interaction/state"
)

type stubStateUpdater struct {
	session domain.Session
	updated bool
}

func (updater stubStateUpdater) build() interactionstate.Updater {
	return interactionstate.NewUpdaterFunc(func(_ interactionstate.StateUpdateInput) (domain.Session, bool) {
		return updater.session, updater.updated
	})
}

type spyStateUpdater struct {
	session   domain.Session
	updated   bool
	lastInput interactionstate.StateUpdateInput
}

func (updater *spyStateUpdater) build() interactionstate.Updater {
	return interactionstate.NewUpdaterFunc(func(input interactionstate.StateUpdateInput) (domain.Session, bool) {
		updater.lastInput = input
		return updater.session, updater.updated
	})
}
