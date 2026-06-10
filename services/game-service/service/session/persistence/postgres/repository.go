package postgres

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/Dylar/ai-trust-game/services/shared/project/domain"
)

const activeStatus = "active"

type Repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

func (repo *Repository) Save(ctx context.Context, sess domain.Session) error {
	state, err := json.Marshal(sess.State)
	if err != nil {
		return err
	}

	_, err = repo.db.ExecContext(ctx, `
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
	`, sess.ID, sess.UserID, sess.Settings.Role, sess.Settings.Mode, activeStatus, string(state), sess.CreatedAt, sess.UpdatedAt)
	return err
}

func (repo *Repository) Get(ctx context.Context, id string) (domain.Session, bool, error) {
	row := repo.db.QueryRowContext(ctx, `
		SELECT id, user_id, role, mode, state, created_at, updated_at
		FROM sessions
		WHERE id = $1
	`, id)

	sess, err := scanSession(row)
	if err == sql.ErrNoRows {
		return domain.Session{}, false, nil
	}
	if err != nil {
		return domain.Session{}, false, err
	}

	return sess, true, nil
}

func (repo *Repository) ListByUserID(ctx context.Context, userID string) ([]domain.Session, error) {
	rows, err := repo.db.QueryContext(ctx, `
		SELECT id, user_id, role, mode, state, created_at, updated_at
		FROM sessions
		WHERE user_id = $1
		ORDER BY updated_at DESC
	`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	sessions := []domain.Session{}
	for rows.Next() {
		sess, err := scanSession(rows)
		if err != nil {
			return nil, err
		}
		sessions = append(sessions, sess)
	}

	return sessions, rows.Err()
}

type sessionScanner interface {
	Scan(dest ...any) error
}

func scanSession(scanner sessionScanner) (domain.Session, error) {
	var sess domain.Session
	var role string
	var mode string
	var stateRaw []byte

	err := scanner.Scan(
		&sess.ID,
		&sess.UserID,
		&role,
		&mode,
		&stateRaw,
		&sess.CreatedAt,
		&sess.UpdatedAt,
	)
	if err != nil {
		return domain.Session{}, err
	}

	var state domain.GameState
	if err := json.Unmarshal(stateRaw, &state); err != nil {
		return domain.Session{}, err
	}

	sess.Settings = domain.GameSettings{
		Role: domain.Role(role),
		Mode: domain.Mode(mode),
	}
	sess.State = state

	return sess, nil
}
