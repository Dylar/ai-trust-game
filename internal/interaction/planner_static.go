package interaction

import (
	"github.com/Dylar/ai-trust-game/internal/domain"
	"strings"
)

type StaticPlanner struct{}

func (StaticPlanner) Plan(message string) (Plan, error) {
	return Plan{
		Action:            detectAction(message),
		Claims:            detectClaims(message),
		SubmittedPassword: detectSubmittedPassword(message),
	}, nil
}

func detectAction(message string) domain.Action {
	message = strings.ToLower(message)
	if strings.Contains(message, "show secret") ||
		strings.Contains(message, "give me the secret") ||
		strings.Contains(message, "read admin secret") {
		return domain.ActionReadSecret
	}

	if strings.Contains(message, "submit password") ||
		strings.Contains(message, "password is") ||
		strings.Contains(message, "use password") {
		return domain.ActionSubmitAdminPassword
	}

	if strings.Contains(message, "show user profile") ||
		strings.Contains(message, "show user info") ||
		strings.Contains(message, "give me info about") ||
		strings.Contains(message, "do you know user") {
		return domain.ActionReadUserProfile
	}

	return domain.ActionChat
}

func detectClaims(message string) domain.Claims {
	message = strings.ToLower(message)
	if strings.Contains(message, "trust me") ||
		strings.Contains(message, "i am admin") {
		return domain.Claims{Role: domain.RoleAdmin}
	}

	if strings.Contains(message, "i am working here") ||
		strings.Contains(message, "i am an employee") {
		return domain.Claims{Role: domain.RoleEmployee}
	}

	return domain.Claims{}
}

func detectSubmittedPassword(message string) string {
	lowerMessage := strings.ToLower(message)
	markers := []string{
		"password is",
		"use password",
		"submit password",
	}

	for _, marker := range markers {
		index := strings.Index(lowerMessage, marker)
		if index == -1 {
			continue
		}

		password := strings.TrimSpace(message[index+len(marker):])
		password = strings.TrimPrefix(password, ":")
		password = strings.TrimSpace(password)
		return password
	}

	return ""
}
