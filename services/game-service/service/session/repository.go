package session

import "github.com/Dylar/ai-trust-game/services/game-service/service/domain"

type Repository interface {
	Save(session domain.Session)
	Get(id string) (domain.Session, bool)
}
