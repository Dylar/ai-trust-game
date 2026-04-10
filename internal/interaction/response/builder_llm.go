package response

import (
	"context"
	"fmt"
	"strings"

	"github.com/Dylar/ai-trust-game/internal/llm"
)

type LLMBuilder struct {
	client llm.Client
}

func NewLLMBuilder(client llm.Client) LLMBuilder {
	return LLMBuilder{client: client}
}

func (builder LLMBuilder) Build(ctx context.Context, input Input) Result {
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
