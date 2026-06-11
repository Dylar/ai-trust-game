package postgres

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/Dylar/ai-trust-game/services/audit-service/service/audit"
	"github.com/google/uuid"
)

type EventRepository struct {
	statements eventStatements
}

func NewEventRepository(db *sql.DB) *EventRepository {
	return &EventRepository{statements: newEventStatements(db)}
}

func (repo *EventRepository) Save(ctx context.Context, event audit.Event) error {
	payload, err := json.Marshal(event)
	if err != nil {
		return err
	}

	return repo.statements.save(ctx, event, uuid.NewString(), string(payload))
}

type RequestAnalysisRepository struct {
	statements requestAnalysisStatements
}

func NewRequestAnalysisRepository(db *sql.DB) *RequestAnalysisRepository {
	return &RequestAnalysisRepository{statements: newRequestAnalysisStatements(db)}
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

	return repo.statements.save(ctx, analysis, string(signals), string(attackPatterns))
}

func (repo *RequestAnalysisRepository) Get(ctx context.Context, requestID string) (audit.RequestAnalysis, bool, error) {
	row := repo.statements.get(ctx, requestID)

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
	rows, err := repo.statements.listBySession(ctx, sessionID)
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
