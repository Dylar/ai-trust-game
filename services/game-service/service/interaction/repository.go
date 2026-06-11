package interaction

import (
	"context"
	"time"
)

type Record struct {
	ID             string
	SessionID      string
	UserID         string
	RequestID      string
	UserInput      string
	SelectedAction string
	PolicyResult   PolicyResult
	ResponseText   string
	Pipeline       Pipeline
	CreatedAt      time.Time
}

type PolicyResult struct {
	Allowed bool   `json:"allowed"`
	Reason  string `json:"reason"`
}

type Pipeline struct {
	ResponseSource string `json:"responseSource"`
}

type Repository interface {
	Save(ctx context.Context, record Record) error
	ListBySession(ctx context.Context, sessionID string) ([]Record, error)
}
