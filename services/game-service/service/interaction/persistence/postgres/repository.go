package postgres

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/Dylar/ai-trust-game/services/game-service/service/interaction"
)

type Repository struct {
	statements interactionStatements
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{statements: newInteractionStatements(db)}
}

func (repo *Repository) Save(ctx context.Context, record interaction.Record) error {
	policyResult, err := json.Marshal(record.PolicyResult)
	if err != nil {
		return err
	}
	pipeline, err := json.Marshal(record.Pipeline)
	if err != nil {
		return err
	}

	_, err = repo.statements.save(ctx, record.ID, record.SessionID, record.UserID, record.RequestID, record.UserInput, string(record.SelectedAction), string(policyResult), record.ResponseText, string(pipeline), record.CreatedAt)
	return err
}

func (repo *Repository) ListBySession(ctx context.Context, sessionID string) ([]interaction.Record, error) {
	rows, err := repo.statements.listBySession(ctx, sessionID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	records := []interaction.Record{}
	for rows.Next() {
		record, err := scanRecord(rows)
		if err != nil {
			return nil, err
		}
		records = append(records, record)
	}
	return records, rows.Err()
}

type recordScanner interface {
	Scan(dest ...any) error
}

func scanRecord(scanner recordScanner) (interaction.Record, error) {
	var record interaction.Record
	var policyResultRaw string
	var pipelineRaw string

	if err := scanner.Scan(
		&record.ID,
		&record.SessionID,
		&record.UserID,
		&record.RequestID,
		&record.UserInput,
		&record.SelectedAction,
		&policyResultRaw,
		&record.ResponseText,
		&pipelineRaw,
		&record.CreatedAt,
	); err != nil {
		return interaction.Record{}, err
	}

	if err := json.Unmarshal([]byte(policyResultRaw), &record.PolicyResult); err != nil {
		return interaction.Record{}, err
	}
	if err := json.Unmarshal([]byte(pipelineRaw), &record.Pipeline); err != nil {
		return interaction.Record{}, err
	}

	return record, nil
}
