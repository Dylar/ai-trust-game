package interaction

import "github.com/Dylar/ai-trust-game/internal/domain"

type Policy interface {
	Decide(input DecisionInput) Decision
}

type DecisionInput struct {
	Session domain.Session
	Action  domain.Action
	Claims  domain.Claims
}

func PolicyFor(mode domain.Mode) Policy {
	switch mode {
	case domain.ModeEasy:
		return PolicyEasy{}
	case domain.ModeMedium:
		return PolicyMedium{}
	case domain.ModeHard:
		return PolicyHard{}
	}
	return nil
}
