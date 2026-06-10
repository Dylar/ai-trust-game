package user

import "context"

type Repository interface {
	List(ctx context.Context) ([]User, error)
	Create(ctx context.Context, displayName string) (User, error)
	Get(ctx context.Context, id string) (User, bool, error)
}
