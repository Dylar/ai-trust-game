package interaction

import (
	"github.com/Dylar/ai-trust-game/internal/domain"
	interactionstate "github.com/Dylar/ai-trust-game/internal/interaction/state"
)

type stubStateUpdater struct {
	session domain.Session
	updated bool
}

func (updater stubStateUpdater) Update(_ interactionstate.Input) (domain.Session, bool) {
	return updater.session, updater.updated
}

type spyStateUpdater struct {
	session   domain.Session
	updated   bool
	lastInput interactionstate.Input
}

func (updater *spyStateUpdater) Update(input interactionstate.Input) (domain.Session, bool) {
	updater.lastInput = input
	return updater.session, updater.updated
}
