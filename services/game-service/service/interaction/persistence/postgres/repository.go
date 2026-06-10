package postgres

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/Dylar/ai-trust-game/services/game-service/service/interaction"
)

type Repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

func (repo *Repository) Save(ctx context.Context, record interaction.Record) error {
	policyResult, err := json.Marshal(record.PolicyResult)
	if err != nil {
		return err
	}
	pipeline, err := json.Marshal(record.Pipeline)
	if err != nil {
		return err
	}

	_, err = repo.db.ExecContext(ctx, `
		INSERT INTO interactions (
			id,
			session_id,
			user_id,
			request_id,
			user_input,
			selected_action,
			policy_result,
			response_text,
			pipeline,
			created_at
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
	`, record.ID, record.SessionID, record.UserID, record.RequestID, record.UserInput, record.SelectedAction, string(policyResult), record.ResponseText, string(pipeline), record.CreatedAt)
	return err
}
