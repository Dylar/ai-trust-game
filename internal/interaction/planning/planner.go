package planning

import (
	"context"
	"strings"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/llm"
)

type Planner struct {
	client llm.Client
}

type Plan struct {
	Action            domain.Action
	Claims            domain.Claims
	SubmittedPassword string
}

func NewStaticPlanner() Planner {
	return NewPlanner(llm.StaticClient{
		GenerateFunc: func(_ context.Context, request llm.Request) (llm.Response, error) {
			return llm.Response{Text: request.UserPrompt}, nil
		},
	})
}

func NewPlanner(client llm.Client) Planner {
	return Planner{client: client}
}

func (planner Planner) Plan(message string) (Plan, error) {
	response, err := planner.client.Generate(context.Background(), llm.Request{
		UserPrompt: message,
	})
	if err != nil {
		return Plan{}, err
	}

	return Plan{
		Action:            detectAction(response.Text),
		Claims:            detectClaims(response.Text),
		SubmittedPassword: detectSubmittedPassword(response.Text),
	}, nil
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
