package audit

import (
	"context"
	"encoding/json"
	"strings"

	"github.com/Dylar/ai-trust-game/internal/llm"
)

type IntentSummarizer interface {
	SummarizeRequest(ctx context.Context, analysis RequestAnalysis, events []Event) (string, error)
	SummarizeSession(ctx context.Context, analysis SessionAnalysis) (string, error)
}

type NoopIntentSummarizer struct{}

func (NoopIntentSummarizer) SummarizeRequest(context.Context, RequestAnalysis, []Event) (string, error) {
	return "", nil
}

func (NoopIntentSummarizer) SummarizeSession(context.Context, SessionAnalysis) (string, error) {
	return "", nil
}

type LLMIntentSummarizer struct {
	client llm.Client
}

func NewLLMIntentSummarizer(client llm.Client) LLMIntentSummarizer {
	if client == nil {
		client = llm.StaticClient{}
	}
	return LLMIntentSummarizer{client: client}
}

func (summarizer LLMIntentSummarizer) SummarizeRequest(
	ctx context.Context,
	analysis RequestAnalysis,
	events []Event,
) (string, error) {
	request := llm.Request{
		Stage:        llm.StageAuditAnalysis,
		SystemPrompt: buildIntentSummarySystemPrompt(),
		UserPrompt:   buildIntentSummaryUserPrompt(analysis, events),
	}

	response, err := summarizer.client.Generate(ctx, request)
	if err != nil {
		return "", err
	}

	return strings.TrimSpace(response.Text), nil
}

func (summarizer LLMIntentSummarizer) SummarizeSession(
	ctx context.Context,
	analysis SessionAnalysis,
) (string, error) {
	request := llm.Request{
		Stage:        llm.StageAuditAnalysis,
		SystemPrompt: buildSessionIntentSummarySystemPrompt(),
		UserPrompt:   buildSessionIntentSummaryUserPrompt(analysis),
	}

	response, err := summarizer.client.Generate(ctx, request)
	if err != nil {
		return "", err
	}

	return strings.TrimSpace(response.Text), nil
}

func buildIntentSummarySystemPrompt() string {
	return strings.Join([]string{
		"You summarize audit traces for a trust and security game.",
		"Write one short sentence that describes the user's likely intent.",
		"Base the summary on observed signals and attack patterns.",
		"Do not mention internal implementation details, JSON, or field names.",
		"Do not invent certainty where the evidence is weak; use wording like 'appears to' when needed.",
	}, "\n")
}

func buildSessionIntentSummarySystemPrompt() string {
	return strings.Join([]string{
		"You summarize a full session of audit traces for a trust and security game.",
		"Write one to two short sentences that describe what the user appeared to do across the session.",
		"Focus on progression, repeated attempts, and overall intent.",
		"Base the summary on the observed request analyses, signals, and attack patterns.",
		"Do not mention internal implementation details, JSON, or field names.",
		"Do not invent certainty where the evidence is weak; use wording like 'appears to' when needed.",
	}, "\n")
}

func buildIntentSummaryUserPrompt(analysis RequestAnalysis, events []Event) string {
	payload := struct {
		Classification Classification `json:"classification"`
		Signals        []string       `json:"signals"`
		AttackPatterns []string       `json:"attack_patterns"`
		Events         []intentEvent  `json:"events"`
	}{
		Classification: analysis.Classification,
		Signals:        analysis.Signals,
		AttackPatterns: analysis.AttackPatterns,
		Events:         make([]intentEvent, 0, len(events)),
	}

	for _, event := range events {
		payload.Events = append(payload.Events, intentEvent{
			Type:      event.Type,
			Step:      event.Step,
			Action:    event.Action,
			Outcome:   event.Outcome,
			Suspicion: event.Suspicion,
			Input:     event.Input,
			Reason:    event.Reason,
		})
	}

	raw, err := json.Marshal(payload)
	if err != nil {
		return ""
	}

	return string(raw)
}

func buildSessionIntentSummaryUserPrompt(analysis SessionAnalysis) string {
	payload := struct {
		Classification Classification         `json:"classification"`
		Signals        []string               `json:"signals"`
		AttackPatterns []string               `json:"attack_patterns"`
		RequestCount   int                    `json:"request_count"`
		Requests       []sessionIntentRequest `json:"requests"`
	}{
		Classification: analysis.Classification,
		Signals:        analysis.Signals,
		AttackPatterns: analysis.AttackPatterns,
		RequestCount:   analysis.RequestCount,
		Requests:       make([]sessionIntentRequest, 0, len(analysis.Requests)),
	}

	for _, request := range analysis.Requests {
		payload.Requests = append(payload.Requests, sessionIntentRequest{
			Classification: request.Classification,
			Signals:        request.Signals,
			AttackPatterns: request.AttackPatterns,
			IntentSummary:  request.IntentSummary,
		})
	}

	raw, err := json.Marshal(payload)
	if err != nil {
		return ""
	}

	return string(raw)
}

type intentEvent struct {
	Type      EventType   `json:"type"`
	Step      Step        `json:"step"`
	Action    interface{} `json:"action"`
	Outcome   Outcome     `json:"outcome"`
	Suspicion string      `json:"suspicion"`
	Input     string      `json:"input"`
	Reason    string      `json:"reason"`
}

type sessionIntentRequest struct {
	Classification Classification `json:"classification"`
	Signals        []string       `json:"signals"`
	AttackPatterns []string       `json:"attack_patterns"`
	IntentSummary  string         `json:"intent_summary"`
}
