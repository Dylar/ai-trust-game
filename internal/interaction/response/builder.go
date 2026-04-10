package response

import (
	"context"

	"github.com/Dylar/ai-trust-game/internal/domain"
)

type Builder interface {
	Build(ctx context.Context, input Input) Result
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
