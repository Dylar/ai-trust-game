package postgres

import (
	"database/sql"
	"errors"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/Dylar/ai-trust-game/services/auth-service/service/user"
	"github.com/jackc/pgx/v5/pgconn"
)

func TestRepositoryList(t *testing.T) {
	db, mock := newMockDB(t)
	defer db.Close()

	now := time.Now().UTC()
	rows := sqlmock.NewRows([]string{"id", "display_name", "created_at", "updated_at"}).
		AddRow("user-1", "Kolja", now, now)
	mock.ExpectQuery("SELECT id, display_name, created_at, updated_at").
		WillReturnRows(rows)

	repo := NewRepository(db)
	users, err := repo.List(t.Context())
	if err != nil {
		t.Fatalf("list users: %v", err)
	}

	if len(users) != 1 {
		t.Fatalf("expected one user, got %d", len(users))
	}
	if users[0].DisplayName != "Kolja" {
		t.Fatalf("expected display name Kolja, got %q", users[0].DisplayName)
	}

	assertExpectations(t, mock)
}

func TestRepositoryCreate(t *testing.T) {
	type Given struct {
		displayName string
		execError   error
	}

	type Then struct {
		expectedError error
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN new display name " +
				"WHEN Create is called " +
				"THEN inserts user",
			given: Given{displayName: "Kolja"},
		},
		{
			name: "GIVEN duplicate display name " +
				"WHEN Create is called " +
				"THEN returns ErrDuplicateDisplayName",
			given: Given{
				displayName: "Kolja",
				execError:   &pgconn.PgError{Code: uniqueViolationCode},
			},
			then: Then{expectedError: user.ErrDuplicateDisplayName},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			db, mock := newMockDB(t)
			defer db.Close()

			expectation := mock.ExpectExec("INSERT INTO users").
				WithArgs(sqlmock.AnyArg(), given.displayName, sqlmock.AnyArg(), sqlmock.AnyArg())
			if given.execError != nil {
				expectation.WillReturnError(given.execError)
			} else {
				expectation.WillReturnResult(sqlmock.NewResult(0, 1))
			}

			repo := NewRepository(db)
			createdUser, err := repo.Create(t.Context(), given.displayName)
			if !errors.Is(err, then.expectedError) {
				t.Fatalf("expected error %v, got %v", then.expectedError, err)
			}
			if then.expectedError == nil && createdUser.DisplayName != given.displayName {
				t.Fatalf("expected display name %q, got %q", given.displayName, createdUser.DisplayName)
			}

			assertExpectations(t, mock)
		})
	}
}

func TestRepositoryGet(t *testing.T) {
	type Given struct {
		userID   string
		rowError error
	}

	type Then struct {
		expectedFound bool
		expectedError error
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN existing user id " +
				"WHEN Get is called " +
				"THEN returns user",
			given: Given{userID: "user-1"},
			then:  Then{expectedFound: true},
		},
		{
			name: "GIVEN missing user id " +
				"WHEN Get is called " +
				"THEN reports not found",
			given: Given{
				userID:   "missing-user",
				rowError: sql.ErrNoRows,
			},
			then: Then{expectedFound: false},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given
		then := scenario.then

		t.Run(scenario.name, func(t *testing.T) {
			db, mock := newMockDB(t)
			defer db.Close()

			query := mock.ExpectQuery("SELECT id, display_name, created_at, updated_at").
				WithArgs(given.userID)
			if given.rowError != nil {
				query.WillReturnError(given.rowError)
			} else {
				now := time.Now().UTC()
				query.WillReturnRows(sqlmock.NewRows([]string{"id", "display_name", "created_at", "updated_at"}).
					AddRow(given.userID, "Kolja", now, now))
			}

			repo := NewRepository(db)
			currentUser, found, err := repo.Get(t.Context(), given.userID)
			if !errors.Is(err, then.expectedError) {
				t.Fatalf("expected error %v, got %v", then.expectedError, err)
			}
			if found != then.expectedFound {
				t.Fatalf("expected found %t, got %t", then.expectedFound, found)
			}
			if then.expectedFound && currentUser.DisplayName != "Kolja" {
				t.Fatalf("expected display name Kolja, got %q", currentUser.DisplayName)
			}

			assertExpectations(t, mock)
		})
	}
}

func newMockDB(t *testing.T) (*sql.DB, sqlmock.Sqlmock) {
	t.Helper()

	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("create sql mock: %v", err)
	}

	return db, mock
}

func assertExpectations(t *testing.T, mock sqlmock.Sqlmock) {
	t.Helper()

	if err := mock.ExpectationsWereMet(); err != nil {
		t.Fatalf("unmet sql expectations: %v", err)
	}
}
