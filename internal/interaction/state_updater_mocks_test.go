package interaction

import "github.com/Dylar/ai-trust-game/internal/domain"

type stubStateUpdater struct {
	session domain.Session
	updated bool
}

func (updater stubStateUpdater) Update(_ StateUpdateInput) (domain.Session, bool) {
	return updater.session, updater.updated
}

type spyStateUpdater struct {
	session   domain.Session
	updated   bool
	lastInput StateUpdateInput
}

func (updater *spyStateUpdater) Update(input StateUpdateInput) (domain.Session, bool) {
	updater.lastInput = input
	return updater.session, updater.updated
}
