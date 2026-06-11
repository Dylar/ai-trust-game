package postgres

import (
	"context"
	"database/sql"
	"time"
)

type userStatements struct {
	db *sql.DB
}

func newUserStatements(db *sql.DB) userStatements {
	return userStatements{db: db}
}

func (stmts userStatements) list(ctx context.Context) (*sql.Rows, error) {
	return stmts.db.QueryContext(ctx, `
		SELECT id, display_name, created_at, updated_at
		FROM users
		ORDER BY updated_at DESC, display_name ASC
	`)
}

func (stmts userStatements) insert(ctx context.Context, id string, displayName string, createdAt time.Time, updatedAt time.Time) (sql.Result, error) {
	return stmts.db.ExecContext(ctx, `
		INSERT INTO users (id, display_name, created_at, updated_at)
		VALUES ($1, $2, $3, $4)
	`, id, displayName, createdAt, updatedAt)
}

func (stmts userStatements) get(ctx context.Context, id string) *sql.Row {
	return stmts.db.QueryRowContext(ctx, `
		SELECT id, display_name, created_at, updated_at
		FROM users
		WHERE id = $1
	`, id)
}
