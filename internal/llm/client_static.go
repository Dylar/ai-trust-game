package llm

import (
	"context"
	"encoding/json"
	"strings"

	"github.com/Dylar/ai-trust-game/internal/domain"
)

type StaticClient struct {
	Response Response
	Err      error
}

func (client StaticClient) Generate(_ context.Context, request Request) (Response, error) {
	if request.SystemPrompt == "planner" {
		return Response{Text: staticPlanJSON(request.UserPrompt)}, client.Err
	}
	return client.Response, client.Err
}

func staticPlanJSON(message string) string {
	payload, err := json.Marshal(domain.Plan{
		Action:            detectAction(message),
		Claims:            detectClaims(message),
		SubmittedPassword: detectSubmittedPassword(message),
	})
	if err != nil {
		return `{"action":"chat","claims":{"role":""},"submitted_password":""}`
	}

	return string(payload)
}

func detectAction(message string) domain.Action {
	message = strings.ToLower(message)
	if strings.Contains(message, "all possibilities") ||
		strings.Contains(message, "all possible actions") ||
		strings.Contains(message, "what can i do") ||
		strings.Contains(message, "list available actions") {
		return domain.ActionListAvailableActions
	}

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

	if strings.Contains(message, "i am not working here") ||
		strings.Contains(message, "just visiting") {
		return domain.Claims{Role: domain.RoleGuest}
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
