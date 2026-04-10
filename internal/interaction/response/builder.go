package response

import (
	"context"
	"fmt"
	"strings"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/llm"
)

type Builder struct {
	client llm.Client
}

type Input struct {
	Session SessionMeta
	Request RequestMeta
	Payload Payload
}

type SessionMeta struct {
	ID   string
	Role domain.Role
	Mode domain.Mode
}

type RequestMeta struct {
	UserMessage       string
	Action            domain.Action
	SubmittedPassword string
	DecisionReason    string
}

type Payload struct {
	AvailableActions []domain.Action
	Secret           string
	UserProfile      *domain.UserProfile
	PasswordCheck    *PasswordCheck
}

type PasswordCheck struct {
	Submitted bool
	Correct   bool
}

type Result struct {
	Message        string
	Source         Source
	UpdatedSession *domain.Session
}

type Source string

const (
	SourceSystem Source = "system"
	SourceLLM    Source = "llm"
)

func NewBuilder(client llm.Client) Builder {
	return Builder{client: client}
}

func (builder Builder) Build(ctx context.Context, input Input) Result {
	if builder.client != nil {
		request := llm.Request{
			SystemPrompt: responseSystemPrompt(),
			UserPrompt:   responseUserPrompt(input),
		}

		response, err := builder.client.Generate(ctx, request)
		if err != nil {
			return Result{
				Message: "I could not generate a response right now.",
				Source:  SourceSystem,
			}
		}

		message := strings.TrimSpace(response.Text)
		if message == "" {
			return Result{
				Message: "",
				Source:  SourceLLM,
			}
		}

		return Result{
			Message: message,
			Source:  SourceLLM,
		}
	}

	switch input.Request.Action {
	case domain.ActionListAvailableActions:
		return buildListAvailableActionsResponse(input)
	case domain.ActionReadSecret:
		return buildReadSecretResponse(input)
	case domain.ActionReadUserProfile:
		return buildReadUserProfileResponse(input)
	case domain.ActionSubmitAdminPassword:
		return buildSubmitAdminPasswordResponse(input)
	}

	return Result{
		Message: fmt.Sprintf("I understood the request, but there is no dedicated response for action %s yet.", input.Request.Action),
		Source:  SourceSystem,
	}
}

func responseSystemPrompt() string {
	return "Generate a concise user-facing response based only on the provided safe interaction data."
}

func responseUserPrompt(input Input) string {
	var prompt strings.Builder

	prompt.WriteString(fmt.Sprintf("session_id=%s\n", input.Session.ID))
	prompt.WriteString(fmt.Sprintf("role=%s\n", input.Session.Role))
	prompt.WriteString(fmt.Sprintf("mode=%s\n", input.Session.Mode))
	prompt.WriteString(fmt.Sprintf("action=%s\n", input.Request.Action))
	prompt.WriteString(fmt.Sprintf("decision_reason=%s\n", input.Request.DecisionReason))
	prompt.WriteString(fmt.Sprintf("user_message=%s\n", input.Request.UserMessage))

	if len(input.Payload.AvailableActions) > 0 {
		actions := make([]string, 0, len(input.Payload.AvailableActions))
		for _, action := range input.Payload.AvailableActions {
			actions = append(actions, string(action))
		}
		prompt.WriteString(fmt.Sprintf("available_actions=%s\n", strings.Join(actions, ", ")))
	}

	if strings.TrimSpace(input.Payload.Secret) != "" {
		prompt.WriteString(fmt.Sprintf("secret=%s\n", input.Payload.Secret))
	}

	if input.Payload.UserProfile != nil {
		profile := input.Payload.UserProfile
		prompt.WriteString(fmt.Sprintf(
			"user_profile=%s %s, born %d, lives in %s, favorite ice cream %s, pet %s\n",
			profile.FirstName,
			profile.LastName,
			profile.BirthYear,
			profile.City,
			profile.FavoriteIceCream,
			profile.Pet,
		))
	}

	if input.Payload.PasswordCheck != nil {
		prompt.WriteString(fmt.Sprintf(
			"password_submitted=%t\npassword_correct=%t\n",
			input.Payload.PasswordCheck.Submitted,
			input.Payload.PasswordCheck.Correct,
		))
	}

	return prompt.String()
}

func buildReadSecretResponse(input Input) Result {
	if strings.TrimSpace(input.Payload.Secret) == "" {
		return Result{
			Message: "I could not find a secret to share.",
			Source:  SourceSystem,
		}
	}

	return Result{
		Message: fmt.Sprintf("The secret is: %s", input.Payload.Secret),
		Source:  SourceSystem,
	}
}

func buildReadUserProfileResponse(input Input) Result {
	if input.Payload.UserProfile == nil {
		return Result{
			Message: "I could not find a user profile.",
			Source:  SourceSystem,
		}
	}

	profile := input.Payload.UserProfile
	return Result{
		Message: fmt.Sprintf(
			"I found this user profile: %s %s, born %d, lives in %s, favorite ice cream %s, pet %s.",
			profile.FirstName,
			profile.LastName,
			profile.BirthYear,
			profile.City,
			profile.FavoriteIceCream,
			profile.Pet,
		),
		Source: SourceSystem,
	}
}

func buildSubmitAdminPasswordResponse(input Input) Result {
	if input.Payload.PasswordCheck == nil || !input.Payload.PasswordCheck.Submitted {
		return Result{
			Message: "I did not receive an admin password to check.",
			Source:  SourceSystem,
		}
	}

	if input.Payload.PasswordCheck.Correct {
		return Result{
			Message: "That admin password is correct.",
			Source:  SourceSystem,
		}
	}

	return Result{
		Message: "That admin password is not correct.",
		Source:  SourceSystem,
	}
}

func buildListAvailableActionsResponse(input Input) Result {
	if len(input.Payload.AvailableActions) == 0 {
		return Result{
			Message: "I could not find any actions you can use right now.",
			Source:  SourceSystem,
		}
	}

	actions := make([]string, 0, len(input.Payload.AvailableActions))
	for _, action := range input.Payload.AvailableActions {
		actions = append(actions, string(action))
	}

	return Result{
		Message: fmt.Sprintf("You can currently use these actions: %s.", strings.Join(actions, ", ")),
		Source:  SourceSystem,
	}
}
