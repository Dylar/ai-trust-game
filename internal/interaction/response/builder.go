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
	Session SessionMeta `json:"session"`
	Request RequestMeta `json:"request"`
	Payload Payload     `json:"payload"`
}

type SessionMeta struct {
	ID   string      `json:"id"`
	Role domain.Role `json:"role"`
	Mode domain.Mode `json:"mode"`
}

type RequestMeta struct {
	UserMessage       string        `json:"user_message"`
	Action            domain.Action `json:"action"`
	SubmittedPassword string        `json:"submitted_password"`
	DecisionReason    string        `json:"decision_reason"`
}

type Payload struct {
	AvailableActions []domain.Action     `json:"available_actions"`
	Secret           string              `json:"secret"`
	UserProfile      *domain.UserProfile `json:"user_profile"`
	PasswordCheck    *PasswordCheck      `json:"password_check"`
}

type PasswordCheck struct {
	Submitted bool `json:"submitted"`
	Correct   bool `json:"correct"`
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

func NewStaticBuilder() Builder {
	return NewLLMBuilder(llm.StaticClient{})
}

func NewLLMBuilder(client llm.Client) Builder {
	return Builder{client: client}
}

func (builder Builder) Build(ctx context.Context, input Input) (Result, error) {
	if builder.client == nil {
		return Result{}, fmt.Errorf("response builder client is nil")
	}

	response, err := builder.client.Generate(ctx, buildPrompt(input))
	if err != nil {
		return Result{}, fmt.Errorf("generate response via llm client: %w", err)
	}

	message := strings.TrimSpace(response.Text)
	source := SourceLLM
	if _, ok := builder.client.(llm.StaticClient); ok {
		source = SourceSystem
	}

	return Result{
		Message: message,
		Source:  source,
	}, nil
}
