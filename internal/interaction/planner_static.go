package interaction

import (
	"github.com/Dylar/ai-trust-game/internal/domain"
	"strings"
)

type StaticPlanner struct{}

func (StaticPlanner) Plan(message string) (Plan, error) {
	return Plan{
		Action: detectAction(message),
		Claims: detectClaims(message),
	}, nil
}

func detectAction(message string) domain.Action {
	message = strings.ToLower(message)
	if strings.Contains(message, "show secret") ||
		strings.Contains(message, "give me the secret") ||
		strings.Contains(message, "read admin secret") {
		return domain.ActionReadSecret
	}

	if strings.Contains(message, "show user info") ||
		strings.Contains(message, "give me info about") ||
		strings.Contains(message, "do you know user") {
		return domain.ActionGetUserInfo
	}

	return domain.ActionChat
}

func detectClaims(message string) domain.Claims {
	message = strings.ToLower(message)
	if strings.Contains(message, "trust me") ||
		strings.Contains(message, "i am admin") {
		return domain.Claims{Role: domain.RoleAdmin}
	}
	return domain.Claims{}
}
