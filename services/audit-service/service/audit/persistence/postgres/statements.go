package postgres

import (
	"context"
	"database/sql"

	"github.com/Dylar/ai-trust-game/services/audit-service/service/audit"
)

type eventStatements struct {
	db *sql.DB
}

func newEventStatements(db *sql.DB) eventStatements {
	return eventStatements{db: db}
}

func (statements eventStatements) save(ctx context.Context, event audit.Event, id string, payload string) error {
	_, err := statements.db.ExecContext(ctx, `
		INSERT INTO audit_events (
			id,
			request_id,
			session_id,
			user_id,
			event_type,
			payload,
			created_at
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`, id, event.RequestID, nullableString(event.SessionID), nullableString(event.UserID), event.Type, payload, event.Timestamp)
	return err
}

type requestAnalysisStatements struct {
	db *sql.DB
}

func newRequestAnalysisStatements(db *sql.DB) requestAnalysisStatements {
	return requestAnalysisStatements{db: db}
}

func (statements requestAnalysisStatements) save(
	ctx context.Context,
	analysis audit.RequestAnalysis,
	signals string,
	attackPatterns string,
) error {
	_, err := statements.db.ExecContext(ctx, `
		INSERT INTO request_analyses (
			request_id,
			user_id,
			session_id,
			started_at,
			completed_at,
			classification,
			signals,
			attack_patterns,
			intent_summary,
			event_count,
			suspicion_count,
			model_fail_count
		)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
		ON CONFLICT (request_id) DO UPDATE SET
			user_id = EXCLUDED.user_id,
			session_id = EXCLUDED.session_id,
			started_at = EXCLUDED.started_at,
			completed_at = EXCLUDED.completed_at,
			classification = EXCLUDED.classification,
			signals = EXCLUDED.signals,
			attack_patterns = EXCLUDED.attack_patterns,
			intent_summary = EXCLUDED.intent_summary,
			event_count = EXCLUDED.event_count,
			suspicion_count = EXCLUDED.suspicion_count,
			model_fail_count = EXCLUDED.model_fail_count
	`, analysis.RequestID, nullableString(analysis.UserID), nullableString(analysis.SessionID), analysis.StartedAt, analysis.CompletedAt, analysis.Classification, signals, attackPatterns, analysis.IntentSummary, analysis.EventCount, analysis.SuspicionCount, analysis.ModelFailCount)
	return err
}

func (statements requestAnalysisStatements) get(ctx context.Context, requestID string) *sql.Row {
	return statements.db.QueryRowContext(ctx, `
		SELECT request_id, user_id, session_id, started_at, completed_at, classification, signals, attack_patterns,
			intent_summary, event_count, suspicion_count, model_fail_count
		FROM request_analyses
		WHERE request_id = $1
	`, requestID)
}

func (statements requestAnalysisStatements) listBySession(ctx context.Context, sessionID string) (*sql.Rows, error) {
	return statements.db.QueryContext(ctx, `
		SELECT request_id, user_id, session_id, started_at, completed_at, classification, signals, attack_patterns,
			intent_summary, event_count, suspicion_count, model_fail_count
		FROM request_analyses
		WHERE session_id = $1
		ORDER BY completed_at ASC, request_id ASC
	`, sessionID)
}
