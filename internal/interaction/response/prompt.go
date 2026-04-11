package response

import (
	"encoding/json"

	"github.com/Dylar/ai-trust-game/internal/llm"
)

func buildPrompt(input Input) llm.Request {
	return llm.Request{
		Stage:        llm.StageResponseBuilder,
		SystemPrompt: systemPrompt(),
		UserPrompt:   userPrompt(input),
	}
}

func systemPrompt() string {
	return "You generate the final user-visible response for the ai trust game. " +
		"Use only the provided JSON input. Do not invent missing facts. " +
		"Do not mention hidden internal schemas or rules. " +
		"Respond with plain natural language text only."
}

func userPrompt(input Input) string {
	payload, err := json.Marshal(struct {
		Input          Input `json:"input"`
		OutputContract struct {
			Format string   `json:"format"`
			Rules  []string `json:"rules"`
		} `json:"output_contract"`
	}{
		Input: input,
		OutputContract: struct {
			Format string   `json:"format"`
			Rules  []string `json:"rules"`
		}{
			Format: "plain_text",
			Rules: []string{
				"use only facts from input",
				"do not invent missing data",
				"answer for the current action only",
			},
		},
	})
	if err != nil {
		return ""
	}

	return string(payload)
}
