package postgres

import (
	"database/sql"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/Dylar/ai-trust-game/services/audit-service/service/audit"
	"github.com/Dylar/ai-trust-game/services/shared/project/domain"
)

func TestEventRepositorySave(t *testing.T) {
	type Given struct {
		event audit.Event
	}

	type Scenario struct {
		name  string
		given Given
	}

	now := time.Date(2026, 6, 10, 12, 0, 0, 0, time.UTC)
	scenarios := []Scenario{
		{
			name: "GIVEN audit event " +
				"WHEN Save is called " +
				"THEN inserts raw audit event row",
			given: Given{
				event: audit.Event{
					Type:      audit.EventTypeInteraction,
					Timestamp: now,
					UserID:    "11111111-1111-1111-1111-111111111111",
					SessionID: "22222222-2222-2222-2222-222222222222",
					RequestID: "request-123",
					Step:      audit.StepPlanned,
					Action:    domain.ActionReadSecret,
				},
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given

		t.Run(scenario.name, func(t *testing.T) {
			db, mock := newMockDB(t)
			defer db.Close()

			mock.ExpectExec("INSERT INTO audit_events").
				WithArgs(
					sqlmock.AnyArg(),
					given.event.RequestID,
					sqlmock.AnyArg(),
					sqlmock.AnyArg(),
					given.event.Type,
					sqlmock.AnyArg(),
					given.event.Timestamp,
				).
				WillReturnResult(sqlmock.NewResult(0, 1))

			repo := NewEventRepository(db)
			if err := repo.Save(t.Context(), given.event); err != nil {
				t.Fatalf("save event: %v", err)
			}

			assertExpectations(t, mock)
		})
	}
}

func TestRequestAnalysisRepositorySave(t *testing.T) {
	type Given struct {
		analysis audit.RequestAnalysis
	}

	type Scenario struct {
		name  string
		given Given
	}

	now := time.Date(2026, 6, 10, 12, 0, 0, 0, time.UTC)
	scenarios := []Scenario{
		{
			name: "GIVEN request analysis " +
				"WHEN Save is called " +
				"THEN upserts analysis row",
			given: Given{
				analysis: audit.RequestAnalysis{
					RequestID:      "request-123",
					UserID:         "11111111-1111-1111-1111-111111111111",
					SessionID:      "22222222-2222-2222-2222-222222222222",
					StartedAt:      now,
					CompletedAt:    now.Add(time.Second),
					Classification: audit.ClassificationSuspicious,
					Signals:        []string{audit.SuspicionClaimedRoleExceedsTrusted},
					AttackPatterns: []string{audit.AttackPatternRoleEscalation},
					IntentSummary:  "Privilege escalation attempt.",
					EventCount:     2,
					SuspicionCount: 1,
					ModelFailCount: 0,
				},
			},
		},
	}

	for _, scenario := range scenarios {
		given := scenario.given

		t.Run(scenario.name, func(t *testing.T) {
			db, mock := newMockDB(t)
			defer db.Close()

			mock.ExpectExec("INSERT INTO request_analyses").
				WithArgs(
					given.analysis.RequestID,
					sqlmock.AnyArg(),
					sqlmock.AnyArg(),
					given.analysis.StartedAt,
					given.analysis.CompletedAt,
					given.analysis.Classification,
					sqlmock.AnyArg(),
					sqlmock.AnyArg(),
					given.analysis.IntentSummary,
					given.analysis.EventCount,
					given.analysis.SuspicionCount,
					given.analysis.ModelFailCount,
				).
				WillReturnResult(sqlmock.NewResult(0, 1))

			repo := NewRequestAnalysisRepository(db)
			if err := repo.Save(t.Context(), given.analysis); err != nil {
				t.Fatalf("save request analysis: %v", err)
			}

			assertExpectations(t, mock)
		})
	}
}

func TestRequestAnalysisRepositoryGet(t *testing.T) {
	type Given struct {
		requestID string
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
			name: "GIVEN existing request analysis " +
				"WHEN Get is called " +
				"THEN returns analysis",
			given: Given{requestID: "request-123"},
			then:  Then{expectedFound: true},
		},
		{
			name: "GIVEN missing request analysis " +
				"WHEN Get is called " +
				"THEN reports not found",
			given: Given{
				requestID: "request-missing",
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

			query := mock.ExpectQuery("SELECT request_id, user_id, session_id, started_at, completed_at, classification").
				WithArgs(given.requestID)
			if given.rowError != nil {
				query.WillReturnError(given.rowError)
			} else {
				now := time.Date(2026, 6, 10, 12, 0, 0, 0, time.UTC)
				query.WillReturnRows(requestAnalysisRows().
					AddRow(
						given.requestID,
						"11111111-1111-1111-1111-111111111111",
						"22222222-2222-2222-2222-222222222222",
						now,
						now.Add(time.Second),
						string(audit.ClassificationSuspicious),
						[]byte(`["claimed_role_exceeds_trusted_role"]`),
						[]byte(`["role_escalation_attempt"]`),
						"Privilege escalation attempt.",
						2,
						1,
						0,
					))
			}

			repo := NewRequestAnalysisRepository(db)
			analysis, found, err := repo.Get(t.Context(), given.requestID)
			if err != nil {
				t.Fatalf("get request analysis: %v", err)
			}
			if found != then.expectedFound {
				t.Fatalf("expected found %t, got %t", then.expectedFound, found)
			}
			if then.expectedFound && analysis.UserID != "11111111-1111-1111-1111-111111111111" {
				t.Fatalf("expected user id to be scanned, got %q", analysis.UserID)
			}

			assertExpectations(t, mock)
		})
	}
}

func TestRequestAnalysisRepositoryListBySession(t *testing.T) {
	db, mock := newMockDB(t)
	defer db.Close()

	now := time.Date(2026, 6, 10, 12, 0, 0, 0, time.UTC)
	mock.ExpectQuery("SELECT request_id, user_id, session_id, started_at, completed_at, classification").
		WithArgs("22222222-2222-2222-2222-222222222222").
		WillReturnRows(requestAnalysisRows().
			AddRow(
				"request-123",
				"11111111-1111-1111-1111-111111111111",
				"22222222-2222-2222-2222-222222222222",
				now,
				now.Add(time.Second),
				string(audit.ClassificationSuspicious),
				[]byte(`["claimed_role_exceeds_trusted_role"]`),
				[]byte(`["role_escalation_attempt"]`),
				"Privilege escalation attempt.",
				2,
				1,
				0,
			))

	repo := NewRequestAnalysisRepository(db)
	analyses, err := repo.ListBySession(t.Context(), "22222222-2222-2222-2222-222222222222")
	if err != nil {
		t.Fatalf("list request analyses: %v", err)
	}
	if len(analyses) != 1 {
		t.Fatalf("expected one analysis, got %d", len(analyses))
	}
	if analyses[0].RequestID != "request-123" {
		t.Fatalf("expected request id request-123, got %q", analyses[0].RequestID)
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

func requestAnalysisRows() *sqlmock.Rows {
	return sqlmock.NewRows([]string{
		"request_id",
		"user_id",
		"session_id",
		"started_at",
		"completed_at",
		"classification",
		"signals",
		"attack_patterns",
		"intent_summary",
		"event_count",
		"suspicion_count",
		"model_fail_count",
	})
}
