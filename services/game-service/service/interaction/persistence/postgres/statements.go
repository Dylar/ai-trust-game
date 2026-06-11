package postgres

import (
	"context"
	"database/sql"
	"time"
)

type interactionStatements struct {
	db *sql.DB
}

func newInteractionStatements(db *sql.DB) interactionStatements {
	return interactionStatements{db: db}
}

func (stmts interactionStatements) save(
	ctx context.Context,
	id string,
	sessionID string,
	userID string,
	requestID string,
	userInput string,
	selectedAction string,
	policyResult string,
	responseText string,
	pipeline string,
	createdAt time.Time,
) (sql.Result, error) {
	return stmts.db.ExecContext(ctx, `
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
	`, id, sessionID, userID, requestID, userInput, selectedAction, policyResult, responseText, pipeline, createdAt)
}

func (stmts interactionStatements) listBySession(ctx context.Context, sessionID string) (*sql.Rows, error) {
	return stmts.db.QueryContext(ctx, `
		SELECT
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
		FROM interactions
		WHERE session_id = $1
		ORDER BY created_at ASC, id ASC
	`, sessionID)
}
