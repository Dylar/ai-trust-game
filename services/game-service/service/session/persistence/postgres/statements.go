package postgres

import (
	"context"
	"database/sql"
	"time"
)

type sessionStatements struct {
	db *sql.DB
}

func newSessionStatements(db *sql.DB) sessionStatements {
	return sessionStatements{db: db}
}

func (stmts sessionStatements) save(
	ctx context.Context,
	id string,
	userID string,
	role string,
	mode string,
	status string,
	state string,
	createdAt time.Time,
	updatedAt time.Time,
) (sql.Result, error) {
	return stmts.db.ExecContext(ctx, `
		INSERT INTO sessions (
			id,
			user_id,
			role,
			mode,
			status,
			state,
			created_at,
			updated_at
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
		ON CONFLICT (id) DO UPDATE SET
			user_id = EXCLUDED.user_id,
			role = EXCLUDED.role,
			mode = EXCLUDED.mode,
			status = EXCLUDED.status,
			state = EXCLUDED.state,
			updated_at = EXCLUDED.updated_at
	`, id, userID, role, mode, status, state, createdAt, updatedAt)
}

func (stmts sessionStatements) get(ctx context.Context, id string) *sql.Row {
	return stmts.db.QueryRowContext(ctx, `
		SELECT id, user_id, role, mode, state, created_at, updated_at
		FROM sessions
		WHERE id = $1
	`, id)
}

func (stmts sessionStatements) listByUserID(ctx context.Context, userID string) (*sql.Rows, error) {
	return stmts.db.QueryContext(ctx, `
		SELECT id, user_id, role, mode, state, created_at, updated_at
		FROM sessions
		WHERE user_id = $1
		ORDER BY updated_at DESC
	`, userID)
}
