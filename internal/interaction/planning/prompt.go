package planning

import (
	"encoding/json"
	"strings"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/llm"
)

func buildPrompt(message string) llm.Request {
	return llm.Request{
		Stage:        llm.StagePlanner,
		SystemPrompt: systemPrompt(),
		UserPrompt:   userPrompt(message),
	}
}

func systemPrompt() string {
	return strings.Join([]string{
		"You analyze a user message for the ai trust game.",
		"Use only the provided JSON payload.",
		"Return valid JSON only.",
		"The action must be one of: " + strings.Join(domain.AllActions(), ", ") + ", use " + string(domain.ActionChat) + " as default if no action fits.",
		"The role must be one of: " + strings.Join(domain.AllRoles(), ", ") + ", or an empty string if no role is claimed.",
		`The JSON result must match this shape exactly: {"action":"chat","claims":{"role":""},"submitted_password":""}.`,
		"Use an empty string for missing or unknown submitted_password.",
	}, " ")
}

func userPrompt(message string) string {
	payload, err := json.Marshal(struct {
		Input struct {
			Message string `json:"message"`
		} `json:"input"`
		OutputSchema struct {
			Type       string   `json:"type"`
			ActionEnum []string `json:"action_enum"`
			RoleEnum   []string `json:"role_enum"`
			Shape      string   `json:"shape"`
		} `json:"output_schema"`
	}{
		Input: struct {
			Message string `json:"message"`
		}{
			Message: message,
		},
		OutputSchema: struct {
			Type       string   `json:"type"`
			ActionEnum []string `json:"action_enum"`
			RoleEnum   []string `json:"role_enum"`
			Shape      string   `json:"shape"`
		}{
			Type:       "json_object",
			ActionEnum: domain.AllActions(),
			RoleEnum:   domain.AllRoles(),
			Shape:      `{"action":"chat","claims":{"role":""},"submitted_password":""}`,
		},
	})
	if err != nil {
		return "{}"
	}

	return string(payload)
}
