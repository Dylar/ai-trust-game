package planning

import (
	_ "embed"
	"encoding/json"
	"strings"

	"github.com/Dylar/ai-trust-game/internal/domain"
	"github.com/Dylar/ai-trust-game/internal/llm"
)

//go:embed prompt_template.json
var promptTemplateJSON []byte

type promptTemplate struct {
	OutputSchema struct {
		Type   string          `json:"type"`
		Schema json.RawMessage `json:"schema"`
	} `json:"output_schema"`
}

func buildPrompt(message string) llm.Request {
	return llm.Request{
		Stage:        llm.StagePlanner,
		SystemPrompt: systemPrompt(),
		UserPrompt:   userPrompt(message),
	}
}

func systemPrompt() string {
	template, err := loadPromptTemplate()
	if err != nil {
		template.OutputSchema.Type = "json_object"
		template.OutputSchema.Schema = []byte(`{"type":"object"}`)
	}

	schemaText := string(template.OutputSchema.Schema)

	return strings.Join([]string{
		"Task:",
		"You analyze one user message for the ai trust game and convert it into a structured plan.",
		"Rules and constraints:",
		"Use only the provided input.",
		"Do not invent actions, roles, or passwords that are not supported by the rules below.",
		"Return valid JSON only and no surrounding explanation.",
		"The action must be one of: " + strings.Join(domain.AllActions(), ", ") + ".",
		"If no action fits, use " + string(domain.ActionChat) + ".",
		"The role must be one of: " + strings.Join(domain.AllRoles(), ", ") + ".",
		"If the user does not clearly claim a role, use an empty string for claims.role.",
		"If no password is present, use an empty string for submitted_password.",
		"If the response language is unclear, use " + domain.DefaultResponseLanguage + ".",
		"Input fields:",
		`input.message: the raw user message that should be analyzed.`,
		"Output fields:",
		`action: the best matching action for the message.`,
		`claims.role: the role explicitly claimed by the user, if any.`,
		`submitted_password: the password text found in the message, if any.`,
		`response_language: the language code to use for the final user-visible response, for example "en" or "de".`,
		"Output JSON Schema:",
		"The output type must be " + template.OutputSchema.Type + ".",
		"The output JSON must validate against this schema: " + schemaText + ".",
	}, " ")
}

func userPrompt(message string) string {
	payload, err := json.Marshal(struct {
		Input struct {
			Message string `json:"message"`
		} `json:"input"`
	}{
		Input: struct {
			Message string `json:"message"`
		}{
			Message: message,
		},
	})
	if err != nil {
		return "{}"
	}

	return string(payload)
}

func loadPromptTemplate() (promptTemplate, error) {
	var template promptTemplate
	if err := json.Unmarshal(promptTemplateJSON, &template); err != nil {
		return promptTemplate{}, err
	}

	return template, nil
}
