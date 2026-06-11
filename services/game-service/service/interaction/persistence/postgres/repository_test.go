package postgres

import (
	"database/sql"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/Dylar/ai-trust-game/services/game-service/service/interaction"
)

func TestRepositorySave(t *testing.T) {
	type Given struct {
		record interaction.Record
	}

	type Scenario struct {
		name  string
		given Given
	}

	now := time.Date(2026, 6, 10, 12, 0, 0, 0, time.UTC)
	scenarios := []Scenario{
		{
			name: "GIVEN interaction record " +
				"WHEN Save is called " +
				"THEN inserts interaction row",
			given: Given{
				record: interaction.Record{
					ID:             "11111111-1111-1111-1111-111111111111",
					SessionID:      "22222222-2222-2222-2222-222222222222",
					UserID:         "33333333-3333-3333-3333-333333333333",
					RequestID:      "request-123",
					UserInput:      "show secret",
					SelectedAction: "read_secret",
					PolicyResult: interaction.PolicyResult{
						Allowed: false,
						Reason:  "guest cannot read secret",
					},
					ResponseText: "interaction denied",
					Pipeline: interaction.Pipeline{
						ResponseSource: "system",
					},
					CreatedAt: now,
				},
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given

		t.Run(scenario.name, func(t *testing.T) {
			db, mock := newMockDB(t)
			defer db.Close()

			mock.ExpectExec("INSERT INTO interactions").
				WithArgs(
					given.record.ID,
					given.record.SessionID,
					given.record.UserID,
					given.record.RequestID,
					given.record.UserInput,
					given.record.SelectedAction,
					sqlmock.AnyArg(),
					given.record.ResponseText,
					sqlmock.AnyArg(),
					given.record.CreatedAt,
				).
				WillReturnResult(sqlmock.NewResult(0, 1))

			repo := NewRepository(db)
			if err := repo.Save(t.Context(), given.record); err != nil {
				t.Fatalf("save interaction record: %v", err)
			}

			assertExpectations(t, mock)
		})
	}
}

func TestRepositoryListBySession(t *testing.T) {
	db, mock := newMockDB(t)
	defer db.Close()

	createdAt := time.Date(2026, 6, 11, 12, 0, 0, 0, time.UTC)
	mock.ExpectQuery("SELECT").
		WithArgs("session-123").
		WillReturnRows(sqlmock.NewRows([]string{
			"id",
			"session_id",
			"user_id",
			"request_id",
			"user_input",
			"selected_action",
			"policy_result",
			"response_text",
			"pipeline",
			"created_at",
		}).AddRow(
			"interaction-123",
			"session-123",
			"user-123",
			"request-123",
			"show secret",
			"read_secret",
			`{"allowed":false,"reason":"guest cannot read secret"}`,
			"interaction denied",
			`{"responseSource":"system"}`,
			createdAt,
		))

	repo := NewRepository(db)
	records, err := repo.ListBySession(t.Context(), "session-123")
	if err != nil {
		t.Fatalf("list interactions: %v", err)
	}

	if len(records) != 1 {
		t.Fatalf("expected one record, got %d", len(records))
	}
	if records[0].ID != "interaction-123" {
		t.Fatalf("expected interaction id, got %q", records[0].ID)
	}
	if records[0].PolicyResult.Allowed {
		t.Fatalf("expected denied policy result")
	}
	if records[0].Pipeline.ResponseSource != "system" {
		t.Fatalf("expected response source system, got %q", records[0].Pipeline.ResponseSource)
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
