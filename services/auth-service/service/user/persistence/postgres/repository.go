package postgres

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/Dylar/ai-trust-game/services/auth-service/service/user"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgconn"
)

const uniqueViolationCode = "23505"

type Repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

func (repo *Repository) List(ctx context.Context) ([]user.User, error) {
	rows, err := repo.db.QueryContext(ctx, `
		SELECT id, display_name, created_at, updated_at
		FROM users
		ORDER BY updated_at DESC, display_name ASC
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	users := []user.User{}
	for rows.Next() {
		currentUser, err := scanUser(rows)
		if err != nil {
			return nil, err
		}
		users = append(users, currentUser)
	}

	return users, rows.Err()
}

func (repo *Repository) Create(ctx context.Context, displayName string) (user.User, error) {
	now := time.Now().UTC()
	createdUser := user.User{
		ID:          uuid.NewString(),
		DisplayName: displayName,
		CreatedAt:   now,
		UpdatedAt:   now,
	}

	_, err := repo.db.ExecContext(ctx, `
		INSERT INTO users (id, display_name, created_at, updated_at)
		VALUES ($1, $2, $3, $4)
	`, createdUser.ID, createdUser.DisplayName, createdUser.CreatedAt, createdUser.UpdatedAt)
	if isUniqueViolation(err) {
		return user.User{}, user.ErrDuplicateDisplayName
	}
	if err != nil {
		return user.User{}, err
	}

	return createdUser, nil
}

func (repo *Repository) Get(ctx context.Context, id string) (user.User, bool, error) {
	row := repo.db.QueryRowContext(ctx, `
		SELECT id, display_name, created_at, updated_at
		FROM users
		WHERE id = $1
	`, id)

	currentUser, err := scanUser(row)
	if errors.Is(err, sql.ErrNoRows) {
		return user.User{}, false, nil
	}
	if err != nil {
		return user.User{}, false, err
	}

	return currentUser, true, nil
}

type userScanner interface {
	Scan(dest ...any) error
}

func scanUser(scanner userScanner) (user.User, error) {
	var currentUser user.User
	err := scanner.Scan(
		&currentUser.ID,
		&currentUser.DisplayName,
		&currentUser.CreatedAt,
		&currentUser.UpdatedAt,
	)
	return currentUser, err
}

func isUniqueViolation(err error) bool {
	var pgErr *pgconn.PgError
	return errors.As(err, &pgErr) && pgErr.Code == uniqueViolationCode
}
