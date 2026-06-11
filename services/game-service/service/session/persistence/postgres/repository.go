package postgres

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/Dylar/ai-trust-game/services/shared/project/domain"
)

const activeStatus = "active"

type Repository struct {
	statements sessionStatements
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{statements: newSessionStatements(db)}
}

func (repo *Repository) Save(ctx context.Context, sess domain.Session) error {
	state, err := json.Marshal(sess.State)
	if err != nil {
		return err
	}

	_, err = repo.statements.save(ctx, sess.ID, sess.UserID, string(sess.Settings.Role), string(sess.Settings.Mode), activeStatus, string(state), sess.CreatedAt, sess.UpdatedAt)
	return err
}

func (repo *Repository) Get(ctx context.Context, id string) (domain.Session, bool, error) {
	row := repo.statements.get(ctx, id)

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
	rows, err := repo.statements.listByUserID(ctx, userID)
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
