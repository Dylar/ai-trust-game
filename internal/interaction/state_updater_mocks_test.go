package interaction

import (
	"github.com/Dylar/ai-trust-game/internal/domain"
	interactionstate "github.com/Dylar/ai-trust-game/internal/interaction/state"
)

type stubStateUpdater struct {
	session domain.Session
	updated bool
}

func (updater stubStateUpdater) Update(_ interactionstate.StateUpdateInput) (domain.Session, bool) {
	return updater.session, updater.updated
}

type spyStateUpdater struct {
	session   domain.Session
	updated   bool
	lastInput interactionstate.StateUpdateInput
}

func (updater *spyStateUpdater) Update(input interactionstate.StateUpdateInput) (domain.Session, bool) {
	updater.lastInput = input
	return updater.session, updater.updated
}
