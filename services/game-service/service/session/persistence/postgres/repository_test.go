package postgres

import (
	"database/sql"
	"encoding/json"
	"errors"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/Dylar/ai-trust-game/services/shared/project/domain"
)

func TestRepositorySave(t *testing.T) {
	type Given struct {
		session domain.Session
	}

	type Scenario struct {
		name  string
		given Given
	}

	now := time.Date(2026, 6, 10, 12, 0, 0, 0, time.UTC)
	scenarios := []Scenario{
		{
			name: "GIVEN session " +
				"WHEN Save is called " +
				"THEN upserts session row",
			given: Given{
				session: domain.Session{
					ID:        "11111111-1111-1111-1111-111111111111",
					UserID:    "22222222-2222-2222-2222-222222222222",
					CreatedAt: now,
					UpdatedAt: now,
					Settings: domain.GameSettings{
						Role: domain.RoleGuest,
						Mode: domain.ModeEasy,
					},
					State: domain.GameState{
						TrustedRole:    domain.RoleGuest,
						SecretUnlocked: true,
					},
				},
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given

		t.Run(scenario.name, func(t *testing.T) {
			db, mock := newMockDB(t)
			defer db.Close()

			mock.ExpectExec("INSERT INTO sessions").
				WithArgs(
					given.session.ID,
					given.session.UserID,
					given.session.Settings.Role,
					given.session.Settings.Mode,
					activeStatus,
					sqlmock.AnyArg(),
					given.session.CreatedAt,
					given.session.UpdatedAt,
				).
				WillReturnResult(sqlmock.NewResult(0, 1))

			repo := NewRepository(db)
			if err := repo.Save(t.Context(), given.session); err != nil {
				t.Fatalf("save session: %v", err)
			}

			assertExpectations(t, mock)
		})
	}
}

func TestRepositoryGet(t *testing.T) {
	type Given struct {
		sessionID string
		rowError  error
	}

	type Then struct {
		expectedFound bool
	}

	type Scenario struct {
		name  string
		given Given
		then  Then
	}

	scenarios := []Scenario{
		{
			name: "GIVEN existing session id " +
				"WHEN Get is called " +
				"THEN returns session",
			given: Given{sessionID: "11111111-1111-1111-1111-111111111111"},
			then:  Then{expectedFound: true},
		},
		{
			name: "GIVEN missing session id " +
				"WHEN Get is called " +
				"THEN reports not found",
			given: Given{
				sessionID: "33333333-3333-3333-3333-333333333333",
				rowError:  sql.ErrNoRows,
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

			query := mock.ExpectQuery("SELECT id, user_id, role, mode, state, created_at, updated_at").
				WithArgs(given.sessionID)
			if given.rowError != nil {
				query.WillReturnError(given.rowError)
			} else {
				now := time.Date(2026, 6, 10, 12, 0, 0, 0, time.UTC)
				query.WillReturnRows(sessionRows(t, now).AddRow(
					given.sessionID,
					"22222222-2222-2222-2222-222222222222",
					string(domain.RoleGuest),
					string(domain.ModeEasy),
					stateJSON(t, domain.GameState{TrustedRole: domain.RoleGuest}),
					now,
					now,
				))
			}

			repo := NewRepository(db)
			sess, found, err := repo.Get(t.Context(), given.sessionID)
			if err != nil {
				t.Fatalf("get session: %v", err)
			}
			if found != then.expectedFound {
				t.Fatalf("expected found %t, got %t", then.expectedFound, found)
			}
			if then.expectedFound && sess.ID != given.sessionID {
				t.Fatalf("expected session id %q, got %q", given.sessionID, sess.ID)
			}

			assertExpectations(t, mock)
		})
	}
}

func TestRepositoryListByUserID(t *testing.T) {
	db, mock := newMockDB(t)
	defer db.Close()

	now := time.Date(2026, 6, 10, 12, 0, 0, 0, time.UTC)
	mock.ExpectQuery("SELECT id, user_id, role, mode, state, created_at, updated_at").
		WithArgs("22222222-2222-2222-2222-222222222222").
		WillReturnRows(sessionRows(t, now).
			AddRow(
				"11111111-1111-1111-1111-111111111111",
				"22222222-2222-2222-2222-222222222222",
				string(domain.RoleGuest),
				string(domain.ModeEasy),
				stateJSON(t, domain.GameState{TrustedRole: domain.RoleGuest}),
				now,
				now,
			))

	repo := NewRepository(db)
	sessions, err := repo.ListByUserID(t.Context(), "22222222-2222-2222-2222-222222222222")
	if err != nil {
		t.Fatalf("list sessions: %v", err)
	}
	if len(sessions) != 1 {
		t.Fatalf("expected one session, got %d", len(sessions))
	}
	if sessions[0].UserID != "22222222-2222-2222-2222-222222222222" {
		t.Fatalf("expected listed session user id, got %q", sessions[0].UserID)
	}

	assertExpectations(t, mock)
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

func sessionRows(t *testing.T, _ time.Time) *sqlmock.Rows {
	t.Helper()

	return sqlmock.NewRows([]string{"id", "user_id", "role", "mode", "state", "created_at", "updated_at"})
}

func stateJSON(t *testing.T, state domain.GameState) []byte {
	t.Helper()

	raw, err := json.Marshal(state)
	if err != nil {
		t.Fatalf("marshal state: %v", err)
	}
	return raw
}

func TestRepositoryGetReturnsScanError(t *testing.T) {
	db, mock := newMockDB(t)
	defer db.Close()

	mock.ExpectQuery("SELECT id, user_id, role, mode, state, created_at, updated_at").
		WithArgs("11111111-1111-1111-1111-111111111111").
		WillReturnError(errors.New("database failed"))

	repo := NewRepository(db)
	_, _, err := repo.Get(t.Context(), "11111111-1111-1111-1111-111111111111")
	if err == nil {
		t.Fatal("expected error")
	}

	assertExpectations(t, mock)
}
