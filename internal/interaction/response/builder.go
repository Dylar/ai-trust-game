package response

import "github.com/Dylar/ai-trust-game/internal/domain"

type Builder interface {
	Build(input Input) Result
}

type Input struct {
	Session           domain.Session
	UserMessage       string
	Action            domain.Action
	SubmittedPassword string
	DecisionReason    string
	AvailableActions  []domain.Action
	Secret            string
	UserProfile       *domain.UserProfile
	PasswordCorrect   bool
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
