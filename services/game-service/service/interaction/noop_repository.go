package interaction

import "context"

type NoopRepository struct{}

func NewNoopRepository() NoopRepository {
	return NoopRepository{}
}

func (NoopRepository) Save(context.Context, Record) error {
	return nil
}
