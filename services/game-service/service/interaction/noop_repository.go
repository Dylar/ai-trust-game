package interaction

import "context"

type NoopRepository struct{}

func NewNoopRepository() NoopRepository {
	return NoopRepository{}
}

func (NoopRepository) Save(context.Context, Record) error {
	return nil
}

func (NoopRepository) ListBySession(context.Context, string) ([]Record, error) {
	return []Record{}, nil
}
