package postgres

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/Dylar/ai-trust-game/services/audit-service/service/audit"
	"github.com/google/uuid"
)

type EventRepository struct {
	db *sql.DB
}

func NewEventRepository(db *sql.DB) *EventRepository {
	return &EventRepository{db: db}
}

func (repo *EventRepository) Save(ctx context.Context, event audit.Event) error {
	payload, err := json.Marshal(event)
	if err != nil {
		return err
	}

	_, err = repo.db.ExecContext(ctx, `
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
	`, uuid.NewString(), event.RequestID, nullableString(event.SessionID), nullableString(event.UserID), event.Type, string(payload), event.Timestamp)
	return err
}

type RequestAnalysisRepository struct {
	db *sql.DB
}

func NewRequestAnalysisRepository(db *sql.DB) *RequestAnalysisRepository {
	return &RequestAnalysisRepository{db: db}
}

func (repo *RequestAnalysisRepository) Save(ctx context.Context, analysis audit.RequestAnalysis) error {
	signals, err := json.Marshal(analysis.Signals)
	if err != nil {
		return err
	}
	attackPatterns, err := json.Marshal(analysis.AttackPatterns)
	if err != nil {
		return err
	}

	_, err = repo.db.ExecContext(ctx, `
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
	`, analysis.RequestID, nullableString(analysis.UserID), nullableString(analysis.SessionID), analysis.StartedAt, analysis.CompletedAt, analysis.Classification, string(signals), string(attackPatterns), analysis.IntentSummary, analysis.EventCount, analysis.SuspicionCount, analysis.ModelFailCount)
	return err
}

func (repo *RequestAnalysisRepository) Get(ctx context.Context, requestID string) (audit.RequestAnalysis, bool, error) {
	row := repo.db.QueryRowContext(ctx, `
		SELECT request_id, user_id, session_id, started_at, completed_at, classification, signals, attack_patterns,
			intent_summary, event_count, suspicion_count, model_fail_count
		FROM request_analyses
		WHERE request_id = $1
	`, requestID)

	analysis, err := scanRequestAnalysis(row)
	if err == sql.ErrNoRows {
		return audit.RequestAnalysis{}, false, nil
	}
	if err != nil {
		return audit.RequestAnalysis{}, false, err
	}

	return analysis, true, nil
}

func (repo *RequestAnalysisRepository) ListBySession(ctx context.Context, sessionID string) ([]audit.RequestAnalysis, error) {
	rows, err := repo.db.QueryContext(ctx, `
		SELECT request_id, user_id, session_id, started_at, completed_at, classification, signals, attack_patterns,
			intent_summary, event_count, suspicion_count, model_fail_count
		FROM request_analyses
		WHERE session_id = $1
		ORDER BY completed_at ASC, request_id ASC
	`, sessionID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	analyses := []audit.RequestAnalysis{}
	for rows.Next() {
		analysis, err := scanRequestAnalysis(rows)
		if err != nil {
			return nil, err
		}
		analyses = append(analyses, analysis)
	}

	return analyses, rows.Err()
}

type requestAnalysisScanner interface {
	Scan(dest ...any) error
}

func scanRequestAnalysis(scanner requestAnalysisScanner) (audit.RequestAnalysis, error) {
	var analysis audit.RequestAnalysis
	var userID sql.NullString
	var sessionID sql.NullString
	var classification string
	var signalsRaw []byte
	var attackPatternsRaw []byte

	err := scanner.Scan(
		&analysis.RequestID,
		&userID,
		&sessionID,
		&analysis.StartedAt,
		&analysis.CompletedAt,
		&classification,
		&signalsRaw,
		&attackPatternsRaw,
		&analysis.IntentSummary,
		&analysis.EventCount,
		&analysis.SuspicionCount,
		&analysis.ModelFailCount,
	)
	if err != nil {
		return audit.RequestAnalysis{}, err
	}

	if userID.Valid {
		analysis.UserID = userID.String
	}
	if sessionID.Valid {
		analysis.SessionID = sessionID.String
	}
	analysis.Classification = audit.Classification(classification)
	if err := json.Unmarshal(signalsRaw, &analysis.Signals); err != nil {
		return audit.RequestAnalysis{}, err
	}
	if err := json.Unmarshal(attackPatternsRaw, &analysis.AttackPatterns); err != nil {
		return audit.RequestAnalysis{}, err
	}

	return analysis, nil
}

func nullableString(value string) sql.NullString {
	return sql.NullString{String: value, Valid: value != ""}
}
